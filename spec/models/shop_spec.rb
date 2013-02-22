#encoding: utf-8

require 'spec_helper'

describe Shop, "商店模型" do

	it{ should belong_to(:user) }
	it{ should have_many(:contents) }
	it{ should have_many(:products) }
	it{ should have_many(:transactions) }
	it{ should have_one(:category) }

	it{ should validate_presence_of(:name) }
	it{ should validate_uniqueness_of(:name) }

	it "检查属性" do
		s = Shop.new
		s.should respond_to(:name)
	end
end
