#encoding: utf-8
require 'spec_helper'

describe User, "用户模型" do

	it{ should have_one(:cart) }
	it{ should have_one(:shop) }
	it{ should have_many(:transactions) }
	it{ should have_many(:addresses) }

	it "检查属性" do
		u = User.new
		u.should respond_to(:uid)
		u.should respond_to(:login)
	end
end
