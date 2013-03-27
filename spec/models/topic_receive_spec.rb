#encoding: utf-8
require 'spec_helper'

describe TopicReceive, "贴子接收人" do

  let(:shop){ FactoryGirl.create(:shop, user: current_user) }

  it{ should belong_to :topic }
  it{ should belong_to :user }

  before :each do
    @topic = shop.topics.create(:user_id => anonymous.id, :content => "就这样吧!")
  end

  def options
    {
      :user_id => anonymous.id,
      :topic_id => @topic.id
    }
  end

  it '拥有属性' do
    treceive = TopicReceive.new
    treceive.should respond_to :user
    treceive.should respond_to :topic
    treceive.should respond_to :user_id
    treceive.should respond_to :topic_id
  end

  it "数据验证" do
    treceive = TopicReceive.create(options)
    treceive.valid?.should be_true

    treceive.user_id = 0
    treceive.valid?.should be_false

    treceive.user_id = anonymous.id
    treceive.valid?.should be_true
  end

  it "接收" do
    expect{
      @topic.receives.create(user_id: anonymous.id)
      @topic.receives.create(user_id: anonymous.id)
      @topic.receives.create(user_id: anonymous.id)
      @topic.receives.create(user_id: anonymous.id)
      }.to change(TopicReceive, :count).by(4)
  end
end
