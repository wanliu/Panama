#encoding: utf-8
require "spec_helper"

describe Admins::Shops::TopicsController, "商店帖子控制器" do
  let(:shop){ FactoryGirl.create(:shop, user: current_user) }
  let(:circle){ new_cricle("客户") }
  let(:category){ FactoryGirl.create(:topic_category, shop: shop) }

  def request_opt
    { shop_id: shop.name }
  end

  def basis_opt
    { status: :circle, user_id: current_user.id }
  end

  def new_cricle(name)
    temp_cricle = shop.circles.find_by(name: name)
    temp_cricle.nil? ? shop.circles.create(name: name) : temp_cricle
  end

  describe "POST create" do

    def topic_options
      {
        content: "我们商店做活动!",
        topic_category_id: category.id
      }
    end

    it "公开发帖" do
      options = topic_options.merge(friends: {"0" =>
        {id: :puliceity, status: :scope}
      })

      xhr :post, :create, request_opt.merge(topic: options), get_session
      response.should be_success
      topic = assigns(:topic)
      topic.valid?.should be_true
      topic.status.name.should eq(:community)
      topic.category.should eq(category)
      topic.receives.map{|r| r.receive }.should eq([shop])
    end

    it "发给某个圈子" do
      options = topic_options.merge(friends: {
        "0" => {id: circle.id, status: "Circle"}
      })

      xhr :post, :create, request_opt.merge(topic: options), get_session
      response.should be_success
      topic = assigns(:topic)
      topic.valid?.should be_true
      topic.status.name.should eq(:circle)
      topic.category.should be_nil
      topic.receives.map{|r| r.receive}.should eq([circle])
    end

    it "发给所有圈子" do
      options = topic_options.merge(friends: {
        "0" => {id: "circle", status: "scope"}
      })
      ancircle = shop.circles.create(name: "某圈子")

      xhr :post, :create, request_opt.merge(topic: options), get_session
      response.should be_success
      topic = assigns(:topic)
      topic.valid?.should be_true
      topic.status.name.should eq(:circle)
      topic.category.should be_nil
      topic.receives.map{|r| r.receive }.should eq(shop.circles)
    end

    it "发给某个用户" do
      anon = anonymous
      options = topic_options.merge(friends: {
        "0" => {id: anon.id, status: "User"}
      })

      xhr :post, :create, request_opt.merge(topic: options), get_session
      response.should be_success
      topic = assigns(:topic)
      topic.valid?.should be_true
      topic.status.name.should eq(:circle)
      topic.category.should be_nil
      topic.receives.map{|r| r.receive }.should eq([anon])
    end

    it "发给圈子与用户" do
      anon = anonymous
      options = topic_options.merge(friends: {
        "0" => {id: anon.id, status: "User"},
        "1" => {id: circle.id, status: "Circle" }
      })

      xhr :post, :create, request_opt.merge(topic: options), get_session
      response.should be_success
      topic = assigns(:topic)
      topic.valid?.should be_true
      topic.status.name.should eq(:circle)
      topic.category.should be_nil
      topic.receives.map{|r| r.receive }.should eq([anon, circle])
    end

    it "带有附件帖子" do
      anon = anonymous
      atta = FactoryGirl.create(:attachment)
      options = topic_options.merge(
        friends: { "1" => {id: circle.id, status: "Circle" } },
        attachments: {
          "0" => atta.id
        })
      xhr :post, :create, request_opt.merge(topic: options), get_session
      topic = assigns(:topic)
      topic.valid?.should be_true
      topic.category.should be_nil
      topic.attachments.map{|a| a.attachment}.should eq([atta])
    end

    it "没有接收对象" do
      anon = anonymous
      options = topic_options.merge(friends: {})

      xhr :post, :create, request_opt.merge(topic: options), get_session
      response.response_code.should eq(403)
    end
  end

  describe "GET index" do
    let(:topic1){ shop.topics.create(basis_opt.merge(content: "去买东西啊！")) }
    let(:topic2){ shop.topics.create(basis_opt.merge(content: "帮我看看这东西怎么样!")) }
    let(:topic3){ shop.topics.create(basis_opt.merge(content: "你买过这东西吗？")) }
    let(:topic4){ shop.topics.create(basis_opt.merge(status: :community,content: "32432fdsa")) }

    before :each do
      topic1.receives.creates([circle])
      topic2.receives.creates([circle])
      topic3.receives.creates([new_cricle("同事")])
      topic4.receives.creates([shop])
    end

    it "获取某个圈子帖子" do
      xhr :get, :index, request_opt.merge(circle_id: circle.id), get_session
      response.should be_success
      assigns(:topics).select{|t| t[:id] == topic1.id}.should_not be_empty
      assigns(:topics).select{|t| t[:id] == topic2.id}.should_not be_empty
      assigns(:topics).select{|t| t[:id] == topic3.id}.should be_empty
    end

    it "获取所有圈子帖子" do
      xhr :get, :index, request_opt.merge(circle_id: "all"), get_session
      assigns(:topics).select{|t| t[:id] == topic1.id}.should_not be_empty
      assigns(:topics).select{|t| t[:id] == topic2.id}.should_not be_empty
      assigns(:topics).select{|t| t[:id] == topic3.id}.should_not be_empty
    end

    it "获取与我相关的帖子" do
      xhr :get, :index, request_opt.merge(circle_id: "community"), get_session
      assigns(:topics).select{|t| t[:id] == topic4.id}.should_not be_empty
      assigns(:topics).select{|t| t[:id] == topic1.id}.should be_empty
      assigns(:topics).select{|t| t[:id] == topic2.id}.should be_empty
      assigns(:topics).select{|t| t[:id] == topic3.id}.should be_empty
    end
  end

  describe "GET my_related" do
    it "与我相关" do
      following = anonymous.followings.shop(shop.id)
      get :my_related, request_opt, get_session
      response.should be_success
      assigns(:circles).should eq(shop.circles)
      assigns(:followers).should eq([following])
      assigns(:categories).should eq(shop.topic_categories)
    end
  end

  describe "GET category" do
    let(:topic1){ shop.topics.create(basis_opt.merge(
      topic_category_id: category.id,
      status: :community,
      content: "去买东西啊！")) }
    let(:topic2){ shop.topics.create(basis_opt.merge(content: "帮我看看这东西怎么样!")) }

    it "根据分类查询帖子" do
      get :category, request_opt.merge(topic_category_id: category.id), get_session
      assigns(:topics).should eq([topic1])
    end
  end

  describe "GET receives" do
    let(:topic2){ shop.topics.create(basis_opt.merge(content: "帮我看看这东西怎么样!")) }

    before do
      @anonymous1, @anonymous2 = anonymous, anonymous
      topic2.receives.creates([@anonymous1, @anonymous2])
    end

    it "获取帖子的接收用户" do
      xhr :get, :receives, request_opt.merge(id: topic2.id), get_session
      topic = assigns(:topic)
      topic.should eq(topic2)
      topic.receive_users.select{|r| r["id"]==@anonymous1.id }.should_not be_empty
      topic.receive_users.select{|r| r["id"]==@anonymous2.id }.should_not be_empty
    end
  end

end