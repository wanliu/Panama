#encoding: utf-8
require 'spec_helper'

describe Admins::Shops::ProductsController do
  let(:shop){ FactoryGirl.create(:shop, ) }
  let(:product){ FactoryGirl.create(:product) }
  let(:current_shop){ {:shop_id => product.shop.name} }

  describe "GET 'index'" do
    it "获取所有产品信息" do
      get 'index',current_shop , get_session
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

  describe 'GET new ' do

    it "显示产品添加页面" do
      get 'new',current_shop , get_session
      response.should be_success
      response.should render_template(:new)
    end
  end

  describe 'POST create' do

    it "添加产品信息" do
      options = {
        :product => {
          :name => "某某产品",
          :price => 1.5,
          :summary => "简单说明一下",
          :description => "描述产品",
          :shop_id => product.shop.id
        }
      }

      post 'create', options, get_session
    end
  end
end
