#encoding: utf-8

require 'spec_helper'

describe Shop, "商店模型" do

    it{ should belong_to(:user) }
    it{ should have_many(:contents) }
    it{ should have_many(:products) }
    it{ should have_many(:transactions) }
    it{ should have_one(:category) }

    it{ should validate_presence_of(:name) }
    it{ should validate_uniqueness_of(:name) }
    it{ should validate_presence_of(:user) }

    def option_attachment
        {
            :name => "测试商店32a",
            :user_id => get_session[:user].id
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
        @shop.user_id.should be_nil
        @shop.save.should be_false
        @shop.user_id = get_session[:user].id
        @shop.save.should be_true
    end

    describe "method fs" do

        it "商店文件系统" do
            @shop.fs.should be_an_instance_of(Vfs::Dir)
        end
    end

    describe "检查模板" do

        it "创建成功" do
            @shop.user_id = get_session[:user].id
            @shop.save.should be_true
            puts @shop.id
        end
    end

    describe "method lookup_content" do

        it "获取主页模板内容 " do
            @shop.user_id = get_session[:user].id
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
end
