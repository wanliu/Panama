#encoding: utf-8
# author: huxinghai

require 'spec_helper'

describe ShopUserGroup, "商店雇员权限组" do

    let(:shop){ FactoryGirl.create(:shop, :user => current_user) }
    let(:sale_group){ FactoryGirl.create(:sale_group, :shop => shop) }
    let(:shop_user){ FactoryGirl.create(:shop_user, :shop => shop, :user => current_user) }

    it{ should belong_to(:shop_group) }
    it{ should belong_to(:shop_user) }

    it{ should belong_to(:shop_group) }
    it{ should belong_to(:shop_user) }


    it "拥有属性" do
        sug = ShopUserGroup.new
        sug.should respond_to(:shop_group_id)
        sug.should respond_to(:shop_user_id)
    end

    it "验证数据" do
        sug = ShopUserGroup.create(:shop_user_id => shop_user.id, :shop_group_id => sale_group.id)
        sug.valid?.should be_true
    end

end
