#encoding: utf-8
require 'spec_helper'

describe ShopUser, "商店雇员模型" do

	it{ should belong_to(:shop) }
	it{ should belong_to(:user) }

	it "验证属性" do
		su = ShopUser.new
		su.should respond_to(:shop_id)
		su.should respond_to(:user_id)
	end

	it "验证数据" do
	end
end
