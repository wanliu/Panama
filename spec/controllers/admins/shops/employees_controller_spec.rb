#encoding: utf-8
require "spec_helper"

describe Admins::Shops::EmployeesController, "商店雇员控制器" do

    let(:shop){ FactoryGirl.create(:shop, :user => current_user) }
    let(:an_shop){ FactoryGirl.create(:shop, :user => current_user) }
    let(:sale_group){ FactoryGirl.create(:sale_group, :shop => shop) }

    def shop_param
      {:shop_id => shop.name}
    end

    before :each do
      @user = anonymous
    end

    describe "GET index" do

      it "获取所有雇员" do
        shop.shop_users.build(:user_id => @user.id).save
        get :index, shop_param, get_session
        response.should be_success
        assigns(:employees).should eq([@user, shop.user])
      end
    end

    describe "POST invite" do

      it "验证正确的数据" do
        post :invite, shop_param.merge(:login => @user.login, :format => :json), get_session
        response.should be_success
        assigns(:user).should eq(@user)
      end

      it "验证无效的数据" do
        post :invite, shop_param.merge(:login => "无效", :format => :json), get_session
        assigns(:user).should be_nil
        response.response_code.should eq(403)
      end

      it "注册用户发邀请信息" do
        expect{
            post :invite, shop_param.merge(:login => @user.login, :format => :json), get_session
        }.to change(Notification, :count).by(1)
      end

      it "E-mail地址发邀请信息" do
        form = "huxinghai198@qq.com"
        post :invite, shop_param.merge(:login => form, :format => :json), get_session
        response.should be_success

        ActionMailer::Base.deliveries.last.to.should eq([form])
      end
    end

    describe "DELETE destroy" do

        it "删除有效雇员" do
            shop.shop_users.create(:user_id => @user.id)
            delete :destroy, shop_param.merge({user_id: @user.id, format: :json, :id => ""}), get_session
            response.should be_success
            shop.find_employee(@user_id).should be_nil
        end

        it "删除无效雇员" do
            delete :destroy, shop_param.merge({user_id: 0, format: :json, :id => ""}), get_session
            response.response_code.should eq(403)
        end
    end

    describe "POST group_join_employee" do

        before :each do
            @opts = shop_param.merge({
                shop_user_id: @user.id,
                shop_group_id: sale_group.id,
                format: :json
            })
        end

        it "有效雇员加入权限组" do
            shop.shop_users.create(:user_id => @user.id)
            post :group_join_employee, @opts, get_session
            response.should be_success
        end

        it "不属于商店雇员加入权限组" do
            post :group_join_employee, @opts, get_session
            response.response_code.should eq(403)
        end

        it "不属于商店的组加入雇员" do
            opts = @opts.merge({:shop_id => an_shop.name})
            post :group_join_employee, opts, get_session
            response.response_code.should eq(403)
        end
    end

    describe "POST group_remove_employee" do

        before :each do
            shop.shop_users.create(:user_id => @user.id)
            @opts = shop_param.merge({
                shop_user_id: @user.id,
                shop_group_id: sale_group.id,
                format: :json
            })
        end

        it "移除雇员权限" do
            sale_group.create_user(@user.id)
            post :group_remove_employee, @opts, get_session

            sale_group.find_user(@user.id).should be_nil
            response.should be_success
        end

        it "组里没有该雇员删除失败" do
            post :group_remove_employee, @opts, get_session
            sale_group.find_user(@opts[:shop_user_id]).should be_nil
            response.response_code.should eq(403)
        end

        it "权限组不存在" do
            post :group_remove_employee, @opts.merge({shop_group_id: 0}), get_session
            response.response_code.should eq(403)
        end
    end

    describe "get find_by_group" do

      it "获取组下所有雇员" do
        shop.shop_users.create(:user_id => @user.id)
        sale_group.create_user(@user.id)
        get :find_by_group, shop_param.merge({group_id: sale_group.id, format: :json}), get_session
        assigns(:employees).should eq([@user, shop.user])
        response.should be_success
      end
    end
end