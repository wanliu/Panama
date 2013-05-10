#encoding: utf-8
require "spec_helper"

describe ChatMessagesController, "聊天记录控制器" do

  before do
    @anony = anonymous

    @message1 = @anony.chat_messages.create(
      :receive_user_id => current_user.id, :content => "什么事啊！")

    @message2 = @anony.chat_messages.create(
      :receive_user_id => current_user.id, :content => "还在吗？")

    @message3 = current_user.chat_messages.create(
      :receive_user_id => @anony.id, :content => "在！")
  end

  describe "GET index" do
    it "通知已经查询信息了" do
      ChatMessage.should_receive(:notice_read_state).with(current_user, anything())
      xhr :get, :index, {friend_id: @anony.id} , get_session
    end

    it "更新查看状态" do
      xhr :get, :index, {friend_id: @anony.id} , get_session
      @message1.reload.read.should be_true
      @message2.reload.read.should be_true
      @message3.reload.read.should be_false
    end

    it "查看某个好友所有聊天信息" do
      xhr :get, :index, {friend_id: @anony.id} , get_session
      assigns(:messages).should eq([@message1, @message2, @message3])
    end
  end

  describe "POST create" do
    it "添加聊天记录" do
      expect{
        xhr :post, :create, {
          chat_message: {receive_user_id: anonymous.id, content: "hello"}
        }, get_session
      }.to change(ChatMessage, :count).by(1)
    end

    it "添加失败" do
      xhr :post, :create, {content: "hello"}, get_session
      assigns(:message).valid?.should be_false
    end
  end

  describe "GET dialogue" do

    it "聊天对话框" do
      anony = anonymous
      get :dialogue, {friend_id: anony.id}, get_session
      response.should be_success
      assigns(:friend).should eq(anony)
    end
  end

  describe "GET read" do
    it "读取未读的信息" do
      xhr :get, :read, {friend_id: @anony.id}, get_session
      @message1.reload.read.should be_true
      @message2.reload.read.should be_true
      @message3.reload.read.should be_false
    end

    it "通知前端已经读取" do
      ChatMessage.should_receive(:notice_read_state)
      xhr :get, :read, {friend_id: @anony.id}, get_session
    end
  end
end