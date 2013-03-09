#encoding: utf-8
# author: huxinghai

require 'spec_helper'

describe ShopGroup, "商店权限组" do

    let(:shop){ FactoryGirl.create(:shop, :user => FactoryGirl.create(:user)) }

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

    it "拥有属性" do
        shop_group = ShopGroup.new
        shop_group.should respond_to(:name)
        shop_group.should respond_to(:shop_id)
    end

    it "验证数据" do
        sg = ShopGroup.create(params)
        sg.valid?.should be_true
        sg.name.should eq(params[:name])
        sg.shop_id.should eq(params[:shop_id])

        sg.name = ""
        sg.valid?.should be_false
    end

    it "获取下面所有用户" do
        #商店加入雇员
        user = anonymous
        shop.employee_users << user
        shop.employee_user(user.id).should_not  be_nil

        sg = ShopGroup.create(params)
        FactoryGirl.create(:shop_user_group,
            :shop_user => shop.employee_user(user.id),
            :shop_group => sg
        )

        sg.users.empty?.should be_false
        sg.users.should eq([user])
    end
end
