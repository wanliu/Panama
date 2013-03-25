#encoding: utf-8
#describe: 关注控制器

require "spec_helper"

describe People::FollowingsController, "关注控制器" do

	let(:shop){ FactoryGirl.create(:shop, user: anonymous) }

	def person_opts
		{person_id: current_user.login}
	end

	describe "GET index 所有关注" do
		before :each do
      @fuser = current_user.followings.user(anonymous.id)
      @fshop = current_user.followings.shop(shop.id)
		end

		it "获取所有" do
			get :index, person_opts, get_session
      response.should be_success
			assigns(:followings).should eq([@fuser, @fshop])
		end

		it "查看别人的关注" do
			get :index, person_opts
      assigns(:followings).should eq([@fuser, @fshop])
		end
	end

  describe "post user 关注用户" do

    it "变更数据" do
      expect{
        xhr :post, :user, person_opts.merge(user_id: anonymous.id), get_session
        }.to change(Following, :count).by(1)
    end

    it "成功" do
      user = anonymous
      xhr :post, :user, person_opts.merge(user_id: user.id), get_session
      assigns(:following).user.should eq(current_user)
      assigns(:following).follow.should eq(user)
    end

    it "失败" do
      xhr :post, :user, person_opts.merge, get_session
      response.response_code.should eq(403)
    end
  end

  describe "post shop 关注商店" do

    it "成功" do
      xhr :post, :shop, person_opts.merge(shop_id: shop.id), get_session
      assigns(:following).user.should eq(current_user)
      assigns(:following).follow.should eq(shop)
    end

    it "失败" do
      xhr :post, :shop, person_opts, get_session
      response.response_code.should eq(403)
    end
  end
end