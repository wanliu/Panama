#encoding: utf-8
require 'spec_helper'

describe ShopsController do

  def valid_attributes
    {
      :name => "某某商店",
      :user_id => get_session[:user].id
    }
  end

  before :each do
    @shop = Shop.new valid_attributes
    @shop.user_id = get_session[:user].id
    @shop.save
  end


  describe "GET index" do
    it "assigns all shops as @shops" do
      get :index, {}, get_session
      assigns(:shops).should include(@shop)
    end
  end

  describe "GET show" do
    it "assigns the requested shop as @shop" do
      get :show, {:id => @shop.to_param}, get_session
      assigns(:shop).should eq(@shop)
    end
  end

  describe "GET new" do
    it "assigns a new shop as @shop" do
      get :new, {}, get_session
      assigns(:shop).should be_a_new(Shop)
    end
  end

  describe "GET edit" do
    it "assigns the requested shop as @shop" do
      get :edit, {:id => @shop.to_param}, get_session
      assigns(:shop).should eq(@shop)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      let(:current_user) { get_session[:user] }
      let(:shop_attributes) {{ name: 'shop_test', user_id: current_user.id }}

      it "creates a new Shop" do
        expect {
          post :create, {:shop => shop_attributes}, get_session
        }.to change(Shop, :count).by(1)
      end

      it "assigns a newly created shop as @shop" do
        post :create, {:shop => shop_attributes}, get_session
        assigns(:shop).should be_a(Shop)
        assigns(:shop).should be_persisted
      end

      it "redirects to the created shop" do
        post :create, {:shop => shop_attributes}, get_session
        response.should redirect_to(Shop.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved shop as @shop" do
        # Trigger the behavior that occurs when invalid params are submitted
        Shop.any_instance.stub(:save).and_return(false)
        post :create, {:shop => {  }}, get_session
        assigns(:shop).should be_a_new(Shop)
      end

      it "re-renders the 'new' template" do
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
