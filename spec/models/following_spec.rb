#encoding: utf-8
require 'spec_helper'

describe Following, "关注模型" do

	it{ should belong_to(:user) }
	it{ should belong_to(:follow) }
	it{ should validate_presence_of(:user) }
	it{ should validate_presence_of(:follow) }

	describe "用户" do
		before :each do
			@user = anonymous
		end

		it "当前用户关注" do
			following = current_user.followings.user(@user.id)
			following.user.should eq(current_user)
			following.follow.should eq(@user)
		end

		it "其它用户关注" do
			following = Following.user(@user.id, current_user.id)
			following.user.should eq(current_user)
			following.follow.should eq(@user)
		end
	end

	describe "商店" do
		let(:shop){ FactoryGirl.create(:shop, user: anonymous) }

		it "当前用户关注" do
			following = current_user.followings.shop(shop.id)
			following.user.should eq(current_user)
			following.follow.should eq(shop)
		end

		it "其它用户关注" do
			following = Following.shop(shop.id, current_user.id)
			following.user.should eq(current_user)
			following.follow.should eq(shop)
		end
	end
end
