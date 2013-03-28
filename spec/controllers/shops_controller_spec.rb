#encoding: utf-8
require 'spec_helper'

describe ShopsController, "商店控制器" do

  def valid_attributes
    {
      :name => "某某商店",
      :user_id => current_user.id
    }
  end

  before :each do
    @shop = Shop.new valid_attributes
    @shop.user_id = current_user.id
    @shop.save
  end

  describe "GET show" do
    it "显示一个商店" do
      get :show, {:id => @shop.to_param}, get_session
      assigns(:shop).should eq(@shop)
    end
  end

  describe "GET new" do
    it "创建商店的页面" do
      get :new, {}, get_session
      assigns(:shop).should be_a_new(Shop)
    end
  end

  describe "GET edit" do
    it "编辑商店的页面" do
      get :edit, {:id => @shop.to_param}, get_session
      assigns(:shop).should eq(@shop)
    end
  end

  describe "POST create" do
    describe "验证有效的参数" do
      let(:shop_attributes) {{ name: 'shop_test', user_id: current_user.id }}

      it "创建成功" do
        expect {
          post :create, {:shop => shop_attributes}, get_session
        }.to change(Shop, :count).by(1)
      end

      it "创建成功返回商店" do
        post :create, {:shop => shop_attributes}, get_session
        assigns(:shop).should be_a(Shop)
        assigns(:shop).should be_persisted
      end

      it "创建成功跳转" do
        post :create, {:shop => shop_attributes}, get_session
        response.should redirect_to(Shop.last)
      end
    end

    describe "无效的参数" do
      it "商店保存失败" do
        # Trigger the behavior that occurs when invalid params are submitted
        Shop.any_instance.stub(:save).and_return(false)
        post :create, {:shop => {  }}, get_session
        assigns(:shop).should be_a_new(Shop)
      end

      it "保存失败重新render创建页面" do
        # Trigger the behavior that occurs when invalid params are submitted
        Shop.any_instance.stub(:save).and_return(false)
        post :create, {:shop => {  }}, get_session
        response.should render_template("new")
      end
    end
  end


  describe "更新操作" do


    describe "有效参数" do
      let(:shop_attributes) {{ name: 'shop_test' }}

      it "更新请求的 shop" do
        Shop.any_instance.should_receive(:update_attributes).with({ "these" => "params" })
        put :update, {:id => @shop.to_param, :shop => { "these" => "params" }}, get_session
      end

      it "assigns the requested shop as @shop" do
        put :update, {:id => @shop.to_param, :shop => valid_attributes}, get_session
        assigns(:shop).should eq(@shop)
      end

      it "redirects to the shop" do
        put :update, {:id => @shop.to_param, :shop => valid_attributes}, get_session
        response.should redirect_to(@shop)
      end
    end


    describe "无效参数" do
      let(:invalid_attributes) {{ :name => nil }}

      it "分配 shop 为 @shop" do
        # Trigger the behavior that occurs when invalid params are submitted
        Shop.any_instance.stub(:save).and_return(false)
        put :update, {:id => @shop.to_param, :shop => invalid_attributes }, get_session
        assigns(:shop).should eq(@shop)
      end

      it "re-renders the 'edit' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Shop.any_instance.stub(:save).and_return(false)
        put :update, {:id => @shop.to_param, :shop => invalid_attributes }, get_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested shop" do
      expect {
        delete :destroy, {:id => @shop.to_param}, get_session
      }.to change(Shop, :count).by(-1)
    end

    it "redirects to the shops list" do
      delete :destroy, {:id => @shop.to_param}, get_session
      response.should redirect_to(shops_url)
    end
  end

end
