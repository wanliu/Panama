#encoding: utf-8
#describe: 贴子

require 'spec_helper'

describe Topic, "贴子模型" do

  let(:shop){ FactoryGirl.create(:shop, user: current_user) }
  let(:topic_category){ FactoryGirl.create(:topic_category, shop: shop) }
  let(:circle){  shop.circles.create(name: "客户") }
  let(:attachment){ FactoryGirl.create(:attachment) }

  it{ should belong_to :user }
  it{ should belong_to :owner }
  it{ should validate_presence_of :user }
  it{ should validate_presence_of :owner }
  it{ should validate_presence_of :content }

  def shop_options
    {
      :user_id => current_user.id,
      :owner_id => shop.id,
      :owner_type => "Shop",
      :content => "我们的商品是安全的..",
      :status => "circle"
    }
  end

  def user_options
    {
      :user_id => current_user.id,
      :owner_id => current_user.id,
      :owner_type => "User",
      :content => "假期一起去打蓝球啊！",
      :status => "circle"
    }
  end

  describe "实例方法" do
    it "拥有属性" do
      topic = Topic.new
      topic.should respond_to :user_id
      topic.should respond_to :owner
      topic.should respond_to :content
      topic.should respond_to :content_html
      topic.should respond_to :status
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
      topic = shop.topics.create(
        :status => :circle,
        :user_id => current_user.id,
        :content => "随着物流上涨，我们商品也涨价")
      topic.valid?.should be_true
    end

    it "个人发贴" do
      topic = current_user.topics.create(
        :status => :circle,
        :user_id => current_user.id,
        :content => "周末去那玩！")
      topic.valid?.should be_true
    end

    it "帖子内容转换带html标签" do
      topic = current_user.topics.create(
        status: :circle,
        user_id: current_user.id,
        content: "啊！  看看这个连接吧 http://google.com"
      )
      topic.valid?.should be_true
      topic.content_html.should_not eq(topic.content)
      clear_html_tag(topic.content_html).gsub(/&nbsp/," ").should eq(topic.content)
    end

    it "帖子加入接收对象" do
      topic = current_user.topics.create(
        :status => :puliceity,
        :user_id => current_user.id,
        :content => "周末去那玩！")
      topic.receives.creates([current_user])
      topic.receives.count.should eq(1)
      topic.receives[0].receive.should eq(current_user)
    end

    it "帖子加入附件" do
      topic = current_user.topics.create(
        :status => :puliceity,
        :user_id => current_user.id,
        :content => "周末去那玩！")

      topic.attachments.creates([attachment])
      topic.attachments.count.should eq(1)
      topic.attachments[0].attachment.should eq(attachment)
    end

    it "帖子所有接收用户" do
      user1, user2, user3 = anonymous, anonymous, anonymous

      topic = Topic.create(shop_options)
      topic.receives.creates([circle])
      circle.join_friend(user1)
      circle.join_friend(user2)
      circle.join_friend(user3)
      topic.receive_users.select{|ruser| ruser["id"] == user1.id }.should_not be_empty
      topic.receive_users.select{|ruser| ruser["id"] == user2.id }.should_not be_empty
      topic.receive_users.select{|ruser| ruser["id"] == user3.id }.should_not be_empty
    end

    it "帖子转换json" do
      topic = Topic.create(shop_options)
      topic.as_json["avatar_url"].should eq(topic.owner.photos.icon)
      topic.as_json["status"].should eq(topic.status.name)
      topic.as_json["send_login"].should eq(topic.user.login)
      topic.as_json["status_name"].should eq(I18n.t("topic.#{topic.status.name}"))
      topic.as_json["attachments"].should be_empty
    end

    it "商圈帖子转换json有分类" do
      topic = Topic.create(shop_options.merge(
        topic_category_id: topic_category.id,
        status: :community))
      topic.receives.creates([shop])

      topic.as_json["avatar_url"].should eq(topic.owner.photos.icon)
      topic.as_json["status"].should eq(topic.status.name)
      topic.as_json["send_login"].should eq(topic.user.login)
      topic.as_json["status_name"].should eq(I18n.t("topic.#{topic.status.name}"))
      topic.as_json["attachments"].should be_empty
      topic.as_json["topic_category_name"].should eq(topic_category.name)
    end

    it "带附件帖子转换json" do
      topic = Topic.create(shop_options)
      topic.attachments.creates([attachment])

      topic.as_json["avatar_url"].should eq(topic.owner.photos.icon)
      topic.as_json["status"].should eq(topic.status.name)
      topic.as_json["send_login"].should eq(topic.user.login)
      topic.as_json["status_name"].should eq(I18n.t("topic.#{topic.status.name}"))
      topic.as_json["attachments"].should_not be_empty
      topic.as_json["attachments"].should eq([attachment.file.url])
    end
  end

  describe "类方法" do

    before :each do
      @topic_shop = Topic.create(shop_options)
      @topic_user = Topic.create(user_options)
    end

    it "获取所有个人帖" do
      anon = anonymous
      topic_anonymous = Topic.create(user_options.merge(
        user_id: anon.id,
        owner_id: anon.id))

      Topic.users.should eq([@topic_user, topic_anonymous])
      Topic.users(owner_id: current_user.id).should eq([@topic_user])
    end

    it "获取所有商店帖" do
      Topic.shops.should eq([@topic_shop])
      Topic.shops(owner_id: shop.id).should eq([@topic_shop])
    end

    it "获取某个商店某个圈子相关帖子" do
      topic = Topic.create(shop_options.merge(content: "去旅游!"))
      topic.receives.creates([circle])
      @topic_shop.receives.creates([circle])

      Topic.find_shop_or_friends(shop, circle).should include(topic, @topic_shop)
    end

    it "获取某个商店所有圈子相关帖子" do
      topic = Topic.create(shop_options.merge(content: "去旅游!"))
      circle_other = shop.circles.create(name: "同事")
      topic.receives.creates([circle])
      @topic_shop.receives.creates([circle_other])

      Topic.find_shop_or_friends(shop, :all).should include(topic, @topic_shop)
    end

    it "获取某个用户某个圈子相关帖子" do
      topic = Topic.create(user_options)
      ucircle = current_user.circles.create(name: "队友")
      topic.receives.creates([ucircle])
      @topic_user.receives.creates([ucircle])

      Topic.find_user_or_friends(current_user, ucircle).should include(topic, @topic_user)
    end

    it "获取某个用户所有圈子相关帖子" do
      topic = Topic.create(user_options)
      circle1 = current_user.circles.create(name: "队友")
      circle2 = current_user.circles.create(name: "同学")
      topic.receives.creates([circle1])
      @topic_user.receives.creates([circle2])

      Topic.find_user_or_friends(current_user, :all).should include(topic, @topic_user)
    end

    it "判断接收级别" do
      receives = {
        "0" => {id: "puliceity", status: "scope"},
        "1" => {id: "external", status: "scope"},
        "2" => {id: "circle", status: "scope"}
      }

      Topic.is_level(receives, "puliceity").should be_true
      Topic.is_level(receives, "external").should be_true
      Topic.is_level(receives, "circle").should be_true
      Topic.is_level(receives, "community").should be_false
    end

    it "商店接收转换" do
      receives = {
        "0" => {id: shop.id, status: "Shop"},
        "1" => {id: anonymous.id, status: "User"},
        "2" => {id: current_user.id, status: "User"}
      }
      receive = Topic.receive_other(receives)
      receive.should eq({status: :community, circles: [shop]})
    end

    it "用户接收转换" do
      anon = anonymous
      receives = {
        "0" => {id: current_user.id, status: "User"},
        "1" => {id: anon.id, status: "User"}
      }
      Topic.receive_other(receives).should eq({
        status: :circle,
        circles: [current_user, anon]})
    end
  end

  def clear_html_tag(content)
    ActionController::Base.helpers.strip_tags(content)
  end
end
