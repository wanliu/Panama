#encoding: utf-8
# describe: 圈子
require 'spec_helper'

describe Circle, "圈子模型" do

  let(:shop){ FactoryGirl.create(:shop, user: current_user) }

  it{ should belong_to :owner }
  it{ should validate_presence_of :name }
  it{ should have_many :friends }

  it "拥有属性" do
    circle = Circle.new
    circle.should respond_to(:name)
    circle.should respond_to(:owner)
  end

  it "验证数据" do
    user = anonymous
    circle = Circle.new(:name => "供应商")
    circle.owner = shop
    circle.save.should be_true
    circle.owner.should eq(shop)

    circle.name = ""
    circle.valid?.should be_false

    circle.name = "供应商"
    circle.valid?.should be_true

    circle.owner = user
    circle.valid?.should be_true
    circle.owner.should eq(user)
  end

  it "商店创建圈子" do
    circle = shop.circles.create(name: "供货商")
    circle.valid?.should be_true
  end

  it "用户创建圈子" do
    user = anonymous
    circle = user.circles.create(name: "同学")
    circle.valid?.should be_true
  end

  describe "圈子加入好友" do
    it "商店圈子" do
      circle = shop.circles.create(name: "供货商")
      circle.join_friend(anonymous)
      circle.join_friend(anonymous)
      circle.join_friend(anonymous)
      circle.friends.count.should eq(3)
    end

    it "用户圈子" do
      user = anonymous
      circle = user.circles.create(name: "同学")
      circle.join_friend(anonymous)
      circle.join_friend(anonymous)
      circle.friends.count.should eq(2)
    end
  end
end
