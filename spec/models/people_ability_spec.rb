#encoding: utf-8
#author: huxinghai
#describe: 个人页面权限
require "spec_helper"

describe PeopleAbility, "个人页面权限" do

    let(:shop){ FactoryGirl.create(:shop, user: anonymous) }
    describe "个人页面拥有者" do

        let(:transaction){ FactoryGirl.create(:transaction, buyer: current_user, seller: shop) }

        before :each do
            @current_ability = PeopleAbility.new(current_user, current_user)
        end

        it "有提醒权限" do
            @current_ability.can?(:index, Notification).should be_true
            @current_ability.can?(:read, Notification).should be_true

            @notification = FactoryGirl.create(:notification,
                :user => current_user, :mentionable_user => anonymous)
            @current_ability.can?(:read, @notification).should be_true

            @notification = FactoryGirl.create(:notification,
                :user => anonymous, :mentionable_user => current_user)
            @current_ability.can?(:read, @notification).should be_false
        end

        it "有购物车权限" do
          @current_ability.can?(:index, Cart).should be_true
          @current_ability.can?(:create, Cart).should be_true
          @current_ability.can?(:destroy, Cart).should be_true
        end

        it "有留言权限" do
          @current_ability.can?(:activity, Comment).should be_true
          @current_ability.can?(:product, Comment).should be_true
        end

        it "有订单权限 " do
            @current_ability.can?(:index, OrderTransaction).should be_true
            @current_ability.can?(:read, OrderTransaction).should be_true
            @current_ability.can?(:batch_create, OrderTransaction).should be_true
            @current_ability.can?(:event, OrderTransaction).should be_true
            @current_ability.can?(:destroy, OrderTransaction).should be_true

            @current_ability.can?(:read, transaction).should be_true
            @current_ability.can?(:event, transaction).should be_true
            @current_ability.can?(:batch_create, transaction).should be_true
        end
    end

    describe "来宾访问者" do
        let(:transaction){ FactoryGirl.create(:transaction, buyer: anonymous, seller: shop) }
        let(:notification){ FactoryGirl.create(:notification,
                :user => current_user, :mentionable_user => anonymous)}

        before :each do
          @current_ability = PeopleAbility.new(current_user, anonymous)
        end

        it "无提醒权限" do
          @current_ability.can?(:index, Notification).should be_false
          @current_ability.can?(:read, Notification).should be_false
          @current_ability.can?(:read, notification).should be_false
        end

        it "有购物车权限" do
          @current_ability.can?(:index, Cart).should be_true
          @current_ability.can?(:create, Cart).should be_true
          @current_ability.can?(:destroy, Cart).should be_true
        end

        it "无留言权限" do
            @current_ability.can?(:activity, Comment).should be_false
            @current_ability.can?(:product, Comment).should be_false
        end

        it "无订单权限 " do
            @current_ability.can?(:index, OrderTransaction).should be_false
            @current_ability.can?(:read, OrderTransaction).should be_false
            @current_ability.can?(:batch_create, OrderTransaction).should be_false
            @current_ability.can?(:event, OrderTransaction).should be_false
            @current_ability.can?(:destroy, OrderTransaction).should be_false

            @current_ability.can?(:read, transaction).should be_false
            @current_ability.can?(:event, transaction).should be_false
            @current_ability.can?(:batch_create, transaction).should be_false
        end
    end

    describe "没登陆访问" do
        before :each do
            @current_ability = PeopleAbility.new(nil, anonymous)
        end

        it "没有权限" do
            @current_ability.cannot :manage, :all
        end
    end
end