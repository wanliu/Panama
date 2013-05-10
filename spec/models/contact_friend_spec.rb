#encoding: utf-8
require 'spec_helper'

describe ContactFriend, "最近联系人模型" do
  it{ should belong_to(:friend) }
  it{ should belong_to(:user) }
  it{ should validate_presence_of(:friend) }
  it{ should validate_presence_of(:user) }

  describe "实例方法" do
    it "json 格式化" do
      contact = current_user.contact_friends.join_friend(anonymous)
      contact.as_json.has_key?("friend").should be_true
      contact.as_json.has_key?("unread_count").should be_true
      contact.as_json.has_key?("state").should be_true
    end
  end

  describe "类方法" do

    it "加入最近联系人" do
      expect{
        current_user.contact_friends.join_friend(anonymous)
      }.to change(ContactFriend, :count).by(1)
    end

    def channel
      "/chat/contact_friends/#{current_user.im_token}"
    end

    it "如果存在最近联系资料，就更新最后联系日期" do
      anony = anonymous
      contact = current_user.contact_friends.join_friend(anony)
      FayeClient.should_receive(:send).with(channel, anything())

      current_user.contact_friends.join_friend(anony).should_not eq(contact.last_contact_date)
    end

    it "变更最近联系人，通知前端" do
      FayeClient.should_receive(:send).with(channel, anything())
      current_user.contact_friends.join_friend(anonymous)
    end
  end
end
