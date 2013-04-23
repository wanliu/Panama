#encoding: utf-8
require "spec_helper"

describe Admins::Shops::CirclesController, "商店圈子控制器" do
  let(:shop){ FactoryGirl.create(:shop, user: current_user) }

  def circle_opt
    { :shop_id => shop.name }
  end

  describe "GET index " do
    it "获取商店所有圈子" do
      shop.circles.create(:name => "认识的人")
      get :index, circle_opt, get_session
      assigns(:circles).should eq(shop.circles)
    end
  end

  describe "POST create" do
    it "添加圈子" do
      xhr :post, :create, circle_opt.merge(:circle => {:name => "认识的人"}), get_session
      response.should be_success
      assigns(:circle).should_not be_nil
      assigns(:circle).name.should eq("认识的人")
    end
  end

  describe "GET show" do
    it "浏览一个圈子" do
      circle = shop.circles.create(:name => "佰生人")
      get :show, circle_opt.merge(:id => circle.id), get_session
      assigns(:circles).should eq(shop.circles)
      assigns(:circle).should eq(circle)
    end
  end

  describe "GET friends" do
    it "获取某个圈子的好友" do
      anon1, anon2 = anonymous, anonymous
      circle = shop.circles.create(:name => "佰生人")
      circle.join_friend(anon1)
      circle.join_friend(anon2)
      xhr :get, :friends, circle_opt.merge(:circle_id => circle.id), get_session
      assigns(:users).select{|u| u["id"]==anon1.id }.should_not be_empty
      assigns(:users).select{|u| u["id"]==anon2.id }.should_not be_empty
    end
  end

  describe "GET all_friends" do
    before do
      @anon1, @anon2 = anonymous, anonymous
      shop.circles.create(:name => "佰生人").join_friend(@anon1)
      shop.circles.create(:name => "不熟悉的人").join_friend(@anon2)
    end

    it "获取所有圈子好友" do
      xhr :get, :all_friends, circle_opt, get_session
      assigns(:users).map{|u| u["id"]}.should eq([@anon1.id, @anon2.id])
    end
  end

  describe "POST join_friend" do
    before do
      @circle = shop.circles.create(:name => "佰生人")
    end

    it "跟某个圈子成功加入好友" do
      anon = anonymous
      xhr :post, :join_friend, circle_opt.merge(
        :user_id => anon.id,
        :id => @circle.id), get_session
      response.should be_success
      JSON.parse(response.body)["id"].should eq(anon.id)
      assigns(:circle).should eq(@circle)
    end

    it "圈子已经存在该好友会失败" do
      anon = anonymous
      @circle.join_friend(anon)
      xhr :post, :join_friend, circle_opt.merge(
        :id => @circle.id,
        :user_id => anon.id), get_session
      response.response_code.should eq(403)
    end

    it "好友没有存在会失败" do
      xhr :post, :join_friend, circle_opt.merge(
        :id => @circle.id,
        :user_id => 0), get_session
      response.response_code.should eq(403)
    end
  end

  describe "DELETE remove_friend" do
    before do
      @circle = shop.circles.create(:name => "佰生人")
    end

    it "移除某个圈子的某个好友" do
      anon = anonymous
      @circle.join_friend(anon)
      xhr :delete, :remove_friend, circle_opt.merge(
        :user_id => anon.id,
        :id => @circle.id), get_session
      response.should be_success
      @circle.friends.find_by(:user_id => anon.id).should be_nil
    end
  end

  describe "DELETE circles_remove_friend" do
    before do
      @anon = anonymous
      shop.circles.create(:name => "佰生人").join_friend(@anon)
      shop.circles.create(:name => "熟悉人").join_friend(@anon)
      shop.circles.create(:name => "不了解的人").join_friend(@anon)
    end

    it "移除所有圈子的某个好友" do
      shop.circle_all_friends.find_by(user_id: @anon.id).should_not be_nil
      xhr :delete, :circles_remove_friend, circle_opt.merge(user_id: @anon.id), get_session
      response.should be_success
      shop.circle_all_friends.find_by(user_id: @anon.id).should be_nil
    end
  end

  describe "GET followers" do

    it "获取关注商店的用户" do
      xhr :get, :followers, circle_opt, get_session
      assigns(:users).should eq(shop.followers.map{|u| u.user})
    end
  end

  describe "DELETE destroy" do
    before do
      @circle = shop.circles.create(:name => "佰生人")
    end

    it "删除某个圈子" do
      Circle.find(@circle.id).should eq(@circle)
      xhr :delete, :destroy, circle_opt.merge(id: @circle.id), get_session
      response.should be_success
      Circle.find_by(:id => @circle.id).should be_nil
    end
  end
end