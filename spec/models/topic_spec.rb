#encoding: utf-8
#describe: 贴子

require 'spec_helper'

describe Topic, "贴子模型" do

  let(:shop){ FactoryGirl.create(:shop, user: current_user) }

  it{ should belong_to :user }
  it{ should belong_to :owner }
  it{ should validate_presence_of :user }
  it{ should validate_presence_of :owner }
  it{ should validate_presence_of :content }

  it "拥有属性" do
    topic = Topic.new
    topic.should respond_to :user_id
    topic.should respond_to :owner
    topic.should respond_to :content
    topic.should respond_to :content_html
  end

  def shop_options
    {
      :user_id => current_user.id,
      :owner_id => shop.id,
      :owner_type => "Shop",
      :content => "我们的产品是安全的.."
    }
  end

  def user_options
    {
      :user_id => current_user.id,
      :owner_id => current_user.id,
      :owner_type => "User",
      :content => "假期一起去打蓝球啊！"
    }
  end

  it "商店发贴 验证数据" do
    topic = Topic.create(shop_options)
    topic.valid?.should be_true
    topic.content = ""
    topic.valid?.should be_false

    topic.content = "fdsa"
    topic.valid?.should be_true

    topic.user_id = 0
    topic.valid?.should be_false

    topic.user_id = current_user.id
    topic.valid?.should be_true

    topic.owner_id = 0
    topic.valid?.should be_false

    topic.owner_id = shop.id
    topic.valid?.should be_true
  end

  it "用户发贴 验证数据" do
    topic = Topic.create(user_options)
    topic.valid?.should be_true
  end

  it "商店发贴" do
    topic = shop.topics.create(:user_id => current_user.id,
      :content => "随着物流上涨，我们产品也涨价")
    topic.valid?.should be_true
  end

  it "用户发贴" do
    topic = shop.topics.create(:user_id => current_user.id,
      :content => "周末去那玩！")
    topic.valid?.should be_true
  end
end
