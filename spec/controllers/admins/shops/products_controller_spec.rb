#encoding: utf-8
require 'spec_helper'

describe Admins::Shops::ProductsController do
  let(:product){ FactoryGirl.create(:product) }

  describe "GET 'index'" do
    it "获取所有产品信息" do
      get 'index', {:shop_id => product.shop.name}, get_session
      response.should be_success

      assigns(:categories).should_not be_nil
      assigns(:products).should_not be_nil
      assigns(:products).count.should eq(1)
      assigns(:products).first.should eq(product)
    end
  end

  describe 'GET show' do

    it "获取单个产品信息" do
      get "show", {:id => product.id}, get_session

      response.should be_success
      assigns(:product).should eq(product)
      assigns(:product).should_not be_nil
    end
  end

  describe 'get new ' do

    it "显示产品添加" do
      get 'new', {:shop_id => product.shop.name}, get_session
      response.should be_success
      response.should render_template(:new)
    end
  end
end
