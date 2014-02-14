#encoding: utf-8
require "spec_helper"

describe People::CirclesController, "个人圈子控制器" do

  def circle_opt
    {
      :person_id => current_user.login,
      :key => :person_id
    }
  end

  describe "GET index " do
    it "获取个人所有圈子" do
      current_user.circles.create(:name => "认识的人")
      get :index, circle_opt, get_session
      assigns(:circles).should eq(current_user.circles)
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
      circle = current_user.circles.create(:name => "佰生人")
      get :show, circle_opt.merge(:id => circle.id), get_session
      assigns(:circles).should eq(current_user.circles)
      assigns(:circle).should eq(circle)
    end
  end

  describe "GET friends" do
    it "获取某个圈子的好友" do
      anon1, anon2 = anonymous, anonymous
      circle = current_user.circles.create(:name => "佰生人")
      circle.join_friend(anon1)
      circle.join_friend(anon2)
      xhr :get, :friends, circle_opt.merge(:circle_id => circle.id), get_session
      assigns(:users).select{|u| u["id"]==anon1.id }.should_not be_empty
      assigns(:users).select{|u| u["id"]==anon2.id }.should_not be_empty
    end
  end

  describe "GET addedyou" do
    before do
      anon = anonymous
      @circle = anon.circles.create(:name => "佰生人")
      @circle.join_friend(current_user)
    end

    it "把你加入的圈子对象" do
      xhr :get, :addedyou, circle_opt, get_session
      assigns(:circles).should eq([@circle])
    end
  end

  describe "GET all_friends" do
    before do
      @anon1, @anon2 = anonymous, anonymous
      current_user.circles.create(:name => "佰生人").join_friend(@anon1)
      current_user.circles.create(:name => "不熟悉的人").join_friend(@anon2)
    end

    it "获取所有圈子好友" do
      xhr :get, :all_friends, circle_opt, get_session
      assigns(:users).map{|u| u["id"]}.should eq([@anon1.id, @anon2.id])
    end
  end

  describe "POST join_friend" do
    before do
      @circle = current_user.circles.create(:name => "佰生人")
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
      @circle = current_user.circles.create(:name => "佰生人")
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
      current_user.circles.create(:name => "佰生人").join_friend(@anon)
      current_user.circles.create(:name => "熟悉人").join_friend(@anon)
      current_user.circles.create(:name => "不了解的人").join_friend(@anon)
    end

    it "移除所有圈子的某个好友" do
      current_user.circle_all_friends.find_by(user_id: @anon.id).should_not be_nil
      xhr :delete, :circles_remove_friend, circle_opt.merge(user_id: @anon.id), get_session
      response.should be_success
      current_user.circle_all_friends.find_by(user_id: @anon.id).should be_nil
    end
  end

  describe "DELETE destroy" do
    before do
      @circle = current_user.circles.create(:name => "佰生人")
    end

    it "删除某个圈子" do
      Circle.find(@circle.id).should eq(@circle)
      xhr :delete, :destroy, circle_opt.merge(id: @circle.id), get_session
      response.should be_success
      Circle.find_by(:id => @circle.id).should be_nil
    end
  end
end