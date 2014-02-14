#encoding: utf-8
# author: huxinghai

require 'spec_helper'

describe ShopGroup, "商店权限组" do

    let(:shop){ FactoryGirl.create(:shop, :user => FactoryGirl.create(:user)) }
    let(:sale_group){ FactoryGirl.create(:sale_group, :shop => shop) }

    it{ should belong_to(:shop) }
    it{ should have_many(:shop_user_groups) }

    it{ should validate_presence_of(:name) }
    it{ should validate_presence_of(:shop) }

    def params
      {
        :name => "customer",
        :shop_id => shop.id
      }
    end

    before :each do
      @user = anonymous
    end

    it "拥有属性" do
      shop_group = ShopGroup.new
      shop_group.should respond_to(:name)
      shop_group.should respond_to(:shop_id)
    end

    it "验证数据" do
      sg = ShopGroup.create(params)
      sg.valid?.should be_false
      sg.shop_id = shop.id
      sg.save.should be_true
      sg.name.should eq(params[:name])
      sg.shop_id.should eq(params[:shop_id])

      sg.name = ""
      sg.valid?.should be_false
    end

    it "添加权限组" do
      ShopGroup.add(shop.id, params).valid?.should be_true
    end

    it "获取下面所有用户" do
      #商店加入雇员
      shop.shop_users.create(:user_id => @user.id)
      shop.find_employee(@user.id).should_not be_nil

      sg = ShopGroup.add(shop.id, params)
      FactoryGirl.create(:shop_user_group,
          :shop_user => shop.find_employee(@user.id),
          :shop_group => sg
      )
      sg.users.empty?.should be_false      
      sg.users.should eq([@user, shop.user])
    end

    it "获取组下面某个用户" do
      shop.shop_users.create(user_id: @user.id)
      sale_group.create_user(@user.id)
      sale_group.find_user(@user.id).should eq(@user)
    end

    context "权限组加入雇员" do
      it "商店的雇员" do
        shop.shop_users.create(user_id: @user.id)
        sale_group.create_user(@user.id).should_not be_nil
        sale_group.find_user(@user.id).should eq(@user)
      end

      it "非商店雇员" do
        sale_group.create_user(@user.id).should be_nil
        sale_group.find_user(@user.id).should be_nil
      end
    end

    context "移除雇员组权限" do
      before :each do
        shop.shop_users.create(user_id: @user.id)
        sale_group.create_user(@user.id)
      end

      it "商店的雇员" do
        sale_group.remove_user(@user.id).should be_true
        sale_group.find_user(@user.id).should be_nil
      end

      it "非商店雇员" do
        sale_group.remove_user(anonymous.id).should be_nil
      end
    end
end
