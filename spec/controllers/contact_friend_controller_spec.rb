#encoding: utf-8
require "spec_helper"

describe ContactFriendsController, "最近联系人控制" do

  before do
    @contact1 = current_user.contact_friends.join_friend(anonymous)
    @contact2 = current_user.contact_friends.join_friend(anonymous)
  end

  describe "GET index" do
    it "获取最近10个联系人" do
      xhr :get, :index, {}, get_session
      assigns(:friends).should eq([@contact1, @contact2])
    end
  end
end