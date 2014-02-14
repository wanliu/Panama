#encoding: utf-8
require 'spec_helper'

describe User, "用户模型" do

  let(:shop){ FactoryGirl.create(:shop, user: current_user) }
  let(:topic_category){ FactoryGirl.create(:topic_category, shop: shop) }

	it{ should have_one(:cart) }
	it{ should have_one(:shop) }
  it{ should have_one(:photo) }
	it{ should have_many(:transactions) }
	it{ should have_many(:addresses) }
  it{ should have_many(:circles) }
  it{ should have_many(:circle_friends) }
  it{ should have_many(:topics) }
  it{ should have_many(:topic_receives) }
  it{ should have_many(:followings) }
  it{ should have_many(:contact_friends) }
  it{ should have_many(:chat_messages) }

	it "检查属性" do
		u = User.new
		u.should respond_to(:uid)
		u.should respond_to(:login)
	end

  it "自动创建购物栏" do
    user1 = FactoryGirl.build(:user)
    user1.cart.should be_a_kind_of(Cart)


    user2 = FactoryGirl.create(:user)
    user2.cart.should be_a_kind_of(Cart)
  end

  it "生成默认图片" do
    user1 = FactoryGirl.build(:user)

    user1.photo.should be_a_kind_of(Image)


    user2 = FactoryGirl.create(:user)

    user2.photo.should be_a_kind_of(Image)
  end

  describe "实例方法" do

    it "加入的圈子" do
      circle = anonymous.circles.create(:name => "佰生人")
      circle.join_friend(current_user)
      current_user.join_circles.should eq([circle])
    end

    it "所有圈子的好友" do
      anon1, anon2 = anonymous, anonymous
      current_user.circles.create(:name => "熟悉人").join_friend(anon1)
      current_user.circles.create(:name => "了解的人").join_friend(anon2)
      current_user.circle_all_friends.map{|f| f.user}.should eq([anon1, anon2])
    end

    it "所有好友的圈子" do
      anon1, anon2 = anonymous, anonymous
      anon1.circles.destroy_all
      anon2.circles.destroy_all
      anon1.circles.create(:name => "fdsa")
      anon2.circles.create(:name => "aaaa")

      current_user.circles.create(:name => "熟悉人").join_friend(anon1)
      current_user.circles.create(:name => "了解的人").join_friend(anon2)
      current_user.all_friend_circles.should eq(anon1.circles + anon2.circles)
    end

    it "关注商家的帖子" do
      anon1 = anonymous
      anon1.followings.shop(shop)
      topic = shop.topics.create(
        :topic_category_id => topic_category.id,
        :user_id => current_user.id,
        :status => :community,
        :content => "我们有活动")
      topic.receives.creates([shop])
      topic.valid?.should be_true
      anon1.following_shop_topics.should eq([topic])
    end

    it "与某个用户聊天信息" do
      anony = anonymous
      ChatMessage.should_receive(:all).with(current_user.id, anony.id)
      current_user.messages(anony.id)
    end

    it "连接状态" do
      RedisClient.redis.should_receive(:exists).with(current_user.redis_key)
      current_user.connect_state
    end

    it "用户连接" do
      RedisClient.redis.should_receive(:set).with(current_user.redis_key, true)
      FayeClient.should_receive(:send).with("/chat/friend/connect/#{current_user.id}", current_user.id)
      current_user.connect
    end

    it "生成及时token" do
      current_user.generate_token
      current_user.im_token.should_not be_nil
    end

    it "用户json" do
      attrs = current_user.as_json
      attrs.has_key?("icon_url").should be_true
      attrs.has_key?("avatar_url").should be_true
      attrs.has_key?("connect_state").should be_true
    end
  end
end
