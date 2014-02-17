#encoding: utf-8
require "spec_helper"
describe Admins::Shops::FollowingsController, "关注商店控制" do
  let(:shop){ FactoryGirl.create(:shop, user: current_user) }
  def shop_opts
    {shop_id: shop.name}
  end
  describe "get index 商店的关注" do
    it "获取" do
      follow = shop.followers.create(user_id: anonymous.id)
      get :index, shop_opts, get_session
      response.should be_success
      assigns(:followings).should eq(follow)
    end
  end
end
