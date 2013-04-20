#encoding: utf-8
#describe: 圈子与用户或者商店关系
require 'spec_helper'

describe CircleFriends, "圈子与用户或者商店关系" do

  let(:shop){ FactoryGirl.create(:shop, user: current_user) }

  before :each do
    @circle = shop.circles.create(name: "供应商")
  end

  it{ should belong_to :circle }
  it{ should belong_to :user }

  it "拥有属性" do
    cfriend = CircleFriends.new
    cfriend.should respond_to :circle
    cfriend.should respond_to :user
    cfriend.should respond_to :user_id
    cfriend.should respond_to :circle_id
  end

  it "验证数据" do
    user = anonymous
    circle_friends = CircleFriends.create(:circle_id => @circle.id,
      :user_id => user.id)
    circle_friends.valid?.should be_true

    circle_friends.circle_id = 0
    circle_friends.valid?.should be_false

    circle_friends.circle_id = @circle.id
    circle_friends.valid?.should be_true

    circle_friends.user_id = 0
    circle_friends.valid?.should be_false

    circle_friends.user_id = user.id
    circle_friends.valid?.should be_true

    CircleFriends.create(:circle_id => @circle.id,
      :user_id => user.id).valid?.should be_false

  end

  it "圈子加入好友" do
    expect{
      @circle.join_friend(anonymous)
      @circle.join_friend(anonymous)
      @circle.join_friend(anonymous)
    }.to change(CircleFriends, :count).by(3)
  end
end