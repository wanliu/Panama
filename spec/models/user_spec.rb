#encoding: utf-8
require 'spec_helper'

describe User, "用户模型" do

	it{ should have_one(:cart) }
	it{ should have_one(:shop) }
  it{ should have_one(:photo) }
	it{ should have_many(:transactions) }
	it{ should have_many(:addresses) }

	it "检查属性" do
		u = User.new
		u.should respond_to(:uid)
		u.should respond_to(:login)
	end

  it "自动创建购物栏" do
    user1 = FactoryGirl.build(:user)

    user1.cart.should be_a_kind_of(Cart)


    user2 = FactoryGirl.create(:user)

    user2.cart.should be_a_kind_of(Cart)
  end

  it "生成默认图片" do
    user1 = FactoryGirl.build(:user)

    user1.photo.should be_a_kind_of(Image)


    user2 = FactoryGirl.create(:user)

    user2.photo.should be_a_kind_of(Image)
  end
end
