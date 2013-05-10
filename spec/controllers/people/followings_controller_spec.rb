#encoding: utf-8
#describe: 关注控制器

require "spec_helper"

describe People::FollowingsController, "关注控制器" do

  let(:shop){ FactoryGirl.create(:shop, user: anonymous) }

  def person_opts
    {
      :person_id => current_user.login
    }
  end

  describe "GET index 所有关注" do
    before :each do
      @fuser = current_user.followings.user(anonymous.id)
      @fshop = current_user.followings.shop(shop.id)
    end

    it "获取所有" do
      get :index, person_opts, get_session
      response.should be_success
      assigns(:u_followings).should eq([@fuser])
      assigns(:s_followings).should eq([@fshop])
    end

    it "查看别人的关注" do
      get :index, person_opts
      assigns(:u_followings).should eq([@fuser])
      assigns(:s_followings).should eq([@fshop])
    end
  end

  describe "post user 关注用户" do

    it "变更数据" do
      expect{
        post :user, person_opts.merge(user_id: anonymous.id, format: :json), get_session
        }.to change(Following, :count).by(1)
    end

    it "成功" do
      user = anonymous
      post :user, person_opts.merge(user_id: user.id, format: :json), get_session
      assigns(:follow).user.should eq(current_user)
      assigns(:follow).follow.should eq(user)
    end
  end

  describe "post shop 关注商店" do

    it "成功" do
      post :shop, person_opts.merge(shop_id: shop.id, format: :json), get_session
      assigns(:follow).user.should eq(current_user)
      assigns(:follow).follow.should eq(shop)
    end
  end

  describe "delete destroy 取消关注" do

    it "用户" do
      follow = current_user.followings.user(anonymous.id)
      delete :destroy, person_opts.merge(id: follow.id, format: :json), get_session
      assigns(:follow).should eq(follow)
      Following.find_by(id: follow.id).should be_nil
    end

    it "商店" do
      follow = current_user.followings.shop(shop.id)
      delete :destroy, person_opts.merge(id: follow.id, format: :json), get_session
      assigns(:follow).should eq(follow)
      Following.find_by(id: follow.id).should be_nil
    end

  end

  describe "get followers 关注我的" do

  end
end