#encoding: utf-8

require 'spec_helper'

describe Shop, "商店模型" do

  it{ should belong_to(:user) }
  it{ should have_many(:contents) }
  it{ should have_many(:products) }
  it{ should have_many(:transactions) }
  it{ should have_one(:shops_category) }
  it{ should have_many(:shop_users) }
  it{ should have_many(:topics) }
  it{ should have_many(:topic_receives) }
  it{ should have_many(:topic_categories) }

  it{ should validate_presence_of(:name) }
  it{ should validate_uniqueness_of(:name) }
  it{ should validate_presence_of(:user) }

  def option_attachment
    {
      :name => "测试商店32a",
      :user => anonymous
    }
  end

  before :each do
    @shop = Shop.new(option_attachment)
  end

  it "检查属性" do
    s = Shop.new
    s.should respond_to(:name)
  end

  it "验证数据" do
      @shop.user_id = be_nil
      @shop.save.should be_false
      @shop.user_id = anonymous.id
      @shop.save.should be_true
  end

  describe "method fs" do

    it "商店文件系统" do
      @shop.fs.should be_an_instance_of(Vfs::Dir)
    end
  end

  describe "检查模板" do

    it "创建成功" do
      @shop.user_id = anonymous.id
      @shop.save.should be_true
        # puts @shop.id
    end
  end

  describe "method lookup_content" do

      it "获取主页模板内容 " do
          @shop.user_id = anonymous.id
          @shop.save
          @shop.lookup_content(:index).should be_an_instance_of(Content)
          @shop.lookup_content(:indexdsa).should be_nil
      end
  end

  it "删除商店数据" do
      name = @shop.name
      @shop.destroy
      fs = "/_shops/#{name}".to_dir
      fs["*"].length.should == 0
  end

  it "查询这商店某个雇员" do
      @shop.user_id = anonymous.id
      @shop.save

      @shop.shop_users.build(:user_id => current_user.id).save
      @shop.find_employee(current_user.id).should_not be_nil
      @shop.employees.should eq([current_user, @shop.user])
  end

  describe "实例方法" do
    let(:shop){ FactoryGirl.create(:shop, user: anonymous) }
    before do
      @circle = shop.circles.create(name: "认识的")
      @anon1, @anon2 = anonymous, anonymous
      @circle.join_friend(@anon1)
      @circle.join_friend(@anon2)
    end

    it "圈子好友" do
      shop.circle_all_friends.map{|f| f.user}.should eq([@anon1, @anon2])
    end

    it "所有好友圈子" do
      circle1 = @anon1.circles.create(name: "团队")
      circle2 = @anon2.circles.create(name: "客户")
      circles = shop.all_friend_circles

      circles.where(:owner_id => @anon1.id).to_a.should eq(@anon1.circles)
      circles.where(:owner_id => @anon2.id).to_a.should eq(@anon2.circles)
    end

    it "商店json" do
      sp = shop.as_json
      sp.has_key?("icon_url").should be_true
    end

    it "获取某个圈子帖子" do
      topic = shop.topics.create(
        status: :community,
        content: "国内标准快递",
        user_id: current_user.id
      )
      topic.receives.creates([@circle])
      shop.all_circle_topics(@circle).should eq([topic])
    end

    it "获取所有圈子帖子" do
      topic = shop.topics.create(
        status: :community,
        content: "国内标准快递",
        user_id: current_user.id
      )
      topic.receives.creates([@circle])
      shop.all_circle_topics(:all).should eq([topic])
    end
  end
end
