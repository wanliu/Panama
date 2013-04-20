#encoding: utf-8
require "spec_helper"

describe People::CirclesController, "圈子控制器" do

  def circle_opt
    { person_id: current_user.login }
  end

  describe "GET index " do
    it "获取个人所有圈子" do
      current_user.circles.create(name: "认识的人")
      get :index, circle_opt, get_session
      assigns(:circles).should eq(current_user.circles)
    end
  end

  describe "POST create" do
    it "添加圈子" do
      post :create, circle_opt.merge(circle: {name: "认识的人"}), get_session
      response.should be_success
      assigns(:circle).should_not be_nil?
      assigns(:circle).name.should eq("认识的人")
    end
  end

  describe "GET show" do
    it "浏览一个圈子" do
      circle = current_user.circles.create(:name => "佰生人")
      get :show, circle_opt.merge(id: circle.id), get_session
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
      xhr :get, :friends, circle_opt.merge(circle_id: circle.id), get_session
      assigns(:users).select{|u| u["id"]==anon1.id }.should be_empty
      assigns(:users).select{|u| u["id"]==anon2.id }.should be_empty
    end
  end
end