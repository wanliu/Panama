#encoding: utf-8
#describe: 权限组
require "spec_helper"

describe Admins::Shops::GroupsController, "权限组控制器" do

    let(:shop){ FactoryGirl.create(:shop, user: current_user) }
    let(:sale_group){ FactoryGirl.create(:sale_group, shop: shop) }
    let(:product_permission){ FactoryGirl.create(:product_permission) }
    let(:user_permission){ FactoryGirl.create(:user_permission) }

    before :each do
        # @user = shop.user
    end

    def shop_opt
        {shop_id: shop.name}
    end

    describe "GET index 某个商店所有组" do
        it "获取所有" do
            group = shop.groups.create(:name => "店长")
            get :index, shop_opt.merge(format: :json), get_session
            response.should be_success
            assigns(:groups).include?(group).should be_true
        end
    end

    describe "GET permissions 某个组的权限" do
        it "获取所有" do
            GroupPermission.create(group_id: sale_group.id,
                permission_id: product_permission.id)
            get :permissions, shop_opt.merge({id: sale_group.id,format: :json}), get_session
            response.should be_success
            assigns(:group).should eq(sale_group)
            assigns(:group).permissions.should eq([product_permission])
        end
    end

    describe "POST check_permissions 给某个组加入权限" do

        before :each do
            @options = shop_opt.merge(permissions: {
                "0" => {status: "true", permission_id: product_permission.id},
                "1" => {status: "true", permission_id: user_permission.id}
            },id: sale_group.id)
        end

        it "加入某个权限" do
            post :check_permissions, @options.merge(format: :json), get_session
            response.should be_success
            assigns(:group).should eq(sale_group)
            assigns(:group).permissions.should eq([product_permission, user_permission])
        end

        it "去除某个权限" do
            sale_group.add_permission([product_permission.id, user_permission.id])

            @options[:permissions]["0"][:status] = "false"
            @options[:permissions]["1"][:status] = "false"
            post :check_permissions, @options.merge(format: :json), get_session
            response.should be_success
            assigns(:group).should eq(sale_group)
            assigns(:group).permissions.include?(product_permission).should be_false
            assigns(:group).permissions.include?(user_permission).should be_false
        end

        it "混合加减权限" do
            sale_group.add_permission([user_permission.id])
            @options[:permissions]["1"][:status] = "false"
            post :check_permissions, @options.merge(format: :json), get_session
            response.should be_success
            sale_group.permissions.include?(user_permission).should be_false
            sale_group.permissions.include?(product_permission).should be_true
        end
    end

    describe "POST create 添加组" do
        it "有效参数" do
            post :create, shop_opt.merge({shop_group: {name: "审查"},format: :json}), get_session
            assigns(:shop_group).valid?.should be_true
        end

        it "无效参数" do
            post :create, shop_opt.merge({shop_group: {name: nil},format: :json}), get_session
            response.response_code.should eq(403)
        end
    end

    describe "DELETE destroy 删除组 " do
        it "成功" do
            ShopGroup.where(:id => sale_group.id).count.should eq(1)
            delete :destroy, shop_opt.merge(format: :json, id: sale_group.id), get_session
            ShopGroup.where(:id => sale_group.id).count.should eq(0)
        end
    end
end