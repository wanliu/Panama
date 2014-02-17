#encoding: utf-8
#author: huxinghai
#describe: 商店权限
require "spec_helper"

describe ShopAbility, "商店权限" do

    let(:shop){ FactoryGirl.create(:shop, user: current_user) }

    describe "商店拥有者" do
        before :each do
            @current_ability = ShopAbility.new(current_user, shop)
        end

        it "所有权限" do
            @current_ability.can?(:manage, :all).should be_true
        end
    end

    describe "商店雇员" do
        let(:shop_user){ FactoryGirl.create(:shop_user, shop: shop, user: anonymous ) }
        let(:sale_group){ FactoryGirl.create(:sale_group, shop: shop) }
        let(:ppers){ FactoryGirl.create(:product_permission) }
        let(:upers){ FactoryGirl.create(:user_permission) }

        before :each do
            sale_group.group_permissions.create(:permission_id => ppers.id)
            sale_group.group_permissions.create(:permission_id => upers.id)
            sale_group.shop_user_groups.create(:shop_user_id => shop_user.id)
            @current_ability = ShopAbility.new(shop_user.user, shop)
        end

        it "权限" do
            product = Kernel.const_get(ppers.resource)
            user = Kernel.const_get(upers.resource)

            @current_ability.can?(ppers.ability, product).should be_true
            @current_ability.can?(upers.ability, user).should be_true
            @current_ability.cannot?(:manage, :all).should be_true
        end
    end

    describe "来宾访问商店" do
        before :each do
            @current_ability = ShopAbility.new(anonymous, shop)
        end

        it "权限" do
            @current_ability.cannot?(:manage, :all).should be_true
        end
    end
end