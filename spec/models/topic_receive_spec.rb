#encoding: utf-8
require 'spec_helper'

describe TopicReceive, "贴子接收人" do

  let(:shop){ FactoryGirl.create(:shop, user: current_user) }

  it{ should belong_to :topic }
  it{ should belong_to :receive }

  before :each do
    @topic = shop.topics.create(:user_id => anonymous.id, :content => "就这样吧!")
  end

  def options
    {
      :receive_id => anonymous.id,
      :receive_type => "User",
      :topic_id => @topic.id
    }
  end

  it '拥有属性' do
    treceive = TopicReceive.new
    treceive.should respond_to :receive
    treceive.should respond_to :topic
    treceive.should respond_to :receive_id
    treceive.should respond_to :receive_type
    treceive.should respond_to :topic_id
  end

  it "数据验证" do
    treceive = TopicReceive.create(options)
    treceive.valid?.should be_true

    treceive.receive_id = 0
    treceive.valid?.should be_false

    treceive.receive_id = anonymous.id
    treceive.valid?.should be_true
  end

  it "用户接收" do
    user = anonymous
    receive = @topic.receives.user(user)
    receive.valid?.should be_true
    receive.receive.should eq(user)
  end

  it "商店接收" do
    ashop = FactoryGirl.create(:shop, user: anonymous)
    receive = @topic.receives.shop(ashop)
    receive.valid?.should be_true
    receive.receive.should eq(ashop)
  end
end
