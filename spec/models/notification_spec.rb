#encoding: utf-8
#author: huxinghai

require 'spec_helper'

describe Notification, "通知模型" do

  it{ should belong_to(:user) }
  it{ should belong_to(:mentionable_user) }

  it{ should validate_presence_of(:user) }
  it{ should validate_presence_of(:mentionable_user) }

  before :each do
    @anonymous = anonymous

    @options = {
        :user_id => @anonymous.id,
        :mentionable_user_id => current_user.id,
        :url => "http://localhost:3000/test",
        :body => "#{current_user.login}在评论提及到你！"
    }
  end



  it "拥有属性" do
    n = Notification.new
    n.should respond_to(:url)
    n.should respond_to(:body)
    n.should respond_to(:user_id)
    n.should respond_to(:mentionable_user_id)
    n.should respond_to(:read)
  end

  it "验证数据" do
    expect{
        Notification.create!(@options)
    }.to change(Notification, :count).by(1)
  end

  it "未读取" do
    n = Notification.create!(@options)

    Notification.unreads.empty?.should be_false
    Notification.unreads.should eq([n])
  end

  it "读取" do
    n = Notification.create!(@options)
    n.update_attribute(:read, true)

    Notification.reads.empty?.should be_false
    Notification.reads.should eq([n])
  end

end
