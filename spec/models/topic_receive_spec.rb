#encoding: utf-8
require 'spec_helper'

describe TopicReceive, "贴子接收人" do

  let(:shop){ FactoryGirl.create(:shop, user: current_user) }
  let(:circle){ new_cricle("认识的") }

  it{ should belong_to :topic }
  it{ should belong_to :receive }

  before :each do
    @topic = shop.topics.create(
      :status => :circle,
      :user_id => anonymous.id,
      :content => "就这样吧!")
  end

  def new_cricle(name)
    tcricle = current_user.circles.find_by(name: name)
    tcricle.nil? ? current_user.circles.create(name: name) : tcricle
  end

  def options
    {
      :receive_id => anonymous.id,
      :receive_type => "User",
      :topic_id => @topic.id
    }
  end

  describe "实例方法" do

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

    it "验证无效通知类型" do
      TopicReceive.create(options.merge(
        receive_type: "Topic", receive_id: @topic.id)).valid?.should be_false

    end

    it "验证用户通知" do
      TopicReceive.create(options.merge(
        receive_type: "User", receive_id: anonymous.id
      )).valid?.should be_true
    end

    it "验证圈子通知" do
      TopicReceive.create(options.merge(
        receive_type: "Circle", receive_id: circle.id
      )).valid?.should be_true
    end

    it "验证商家通知" do
      TopicReceive.create(options.merge(
        receive_type: "Shop", receive_id: shop.id
      )).valid?.should be_true
    end
  end

  describe "类方法" do
    before do
      circle.join_friend(anonymous)
      circle.join_friend(anonymous)
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

    it "加入多个接收者应该有变更" do
      expect{
        @topic.receives.creates([anonymous, anonymous, circle])
      }.to change(TopicReceive, :count).by(3)
    end

    it "加入多个接收者" do
      receives = [anonymous, anonymous, circle]
      @topic.receives.creates(receives)
      @topic.receives.map{|r| r.receive}.should eq(receives)
    end

    it "与某个用户相关" do
      anon = anonymous
      @topic.receives.creates([anon])
      TopicReceive.user_related(anon.id).map{|t| t.receive}.should eq([anon])
    end

    it "与某个商店相关" do
      @topic.receives.creates([shop])
      TopicReceive.shop_related(shop.id).map{|t| t.receive}.should eq([shop])
    end

    it "与某个圈子相关" do
      @topic.receives.creates([circle])
      TopicReceive.circle_related(circle.id).map{|t| t.receive}.should eq([circle])
    end

    it "加入某个用户接收" do
      anon = anonymous
      @topic.receives.user(anon).valid?.should be_true
      @topic.receives.user(anon).receive.should eq(anon)
    end

    it "加入某个商店接收" do
      @topic.receives.shop(shop).valid?.should be_true
      @topic.receives.shop(shop).receive.should eq(shop)
    end

    it "加入某个圈子" do
      @topic.receives.circle(circle).valid?.should be_true
      @topic.receives.circle(circle).receive.should eq(circle)
    end
  end
end