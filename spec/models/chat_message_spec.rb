#encoding: utf-8
require 'spec_helper'

describe ChatMessage, "聊天记录模型" do

  it{ should belong_to(:receive_user) }
  it{ should belong_to(:send_user) }

  it{ should validate_presence_of :receive_user }
  it{ should validate_presence_of :send_user }
  it{ should validate_presence_of :content }

  it "验证属性" do
    message = ChatMessage.new
    message.should respond_to(:send_user)
    message.should respond_to(:receive_user)
    message.should respond_to(:content)
    message.read.should be_false
  end

  describe "实例方法" do
    before do
      @anony = anonymous
      @message1 = current_user.chat_messages.create(
        :receive_user => @anony, :content => "这价格包邮吗？")
      @message2 = @anony.chat_messages.create(
        :receive_user => current_user, :content => "不包邮!" )
      @message3 = current_user.chat_messages.create(
        :receive_user => anonymous, :content => "这商品好不好！")
    end

    it "所有未读信息" do
      @message3.change_state
      ChatMessage.unread.should eq([@message1, @message2])
    end

    it "所有已读信息" do
      @message1.change_state
      @message2.change_state
      ChatMessage.read.should eq([@message1, @message2])
    end

    it "获取与某个用户所有聊天记录" do
      ChatMessage.all(current_user.id, @anony.id).should eq([@message1, @message2])
    end

    it "获取所有的聊天记录" do
      ChatMessage.all.should eq([@message1, @message2, @message3])
    end

    it "发送信息之前建立最近联系人" do
      message = current_user.chat_messages.build(
        :receive_user => @anony, :content => "东西怎么样!")
      message.should_receive(:join_contact_friend).with(no_args())
      message.save.should be_true
    end

    it "发送信息之后通知接收人" do
      message = current_user.chat_messages.build(
        :receive_user => @anony, :content => "东西怎么样!")
      message.should_receive(:notic_receive_user).with(no_args())
      message.save.should be_true
    end

    it "标识信息已读状态" do
      @message1.should_receive(:update_attribute).with(:read, true).once
      ChatMessage.should_receive(:notice_read_state).with(@message1.receive_user, @message1.send_user_id).once
      @message1.change_state
    end

    it "转换json" do
      @message1.as_json.has_key?("receive_user").should be_true
      @message1.as_json.has_key?("send_user").should be_true
    end
  end

  describe "类方法" do

    it "通知已经读取信息" do
      anony = anonymous
      channel = "/chat/change/message/#{anony.im_token}"
      FayeClient.should_receive(:send).with(channel, current_user.id)
      ChatMessage.notice_read_state(anony, current_user.id)
    end
  end
end
