#encoding: utf-8
require 'spec_helper'

describe Admins::Shops::ProductsController do

  let(:shop){ FactoryGirl.create(:shop, :user => current_user ) }
  let(:category){ FactoryGirl.create(:category) }
  let(:shops_category){ FactoryGirl.create(:yifu, :shop => shop) }
  let(:product){ FactoryGirl.create(:product,
                                    :shop => shop,
                                    :category => category,
                                    :shops_category => shops_category) }
  let(:current_shop){ {:shop_id => shop.name} }
  let(:default_attachment){ FactoryGirl.create(:attachment) }
  let(:attachment){ FactoryGirl.create(:attachment) }

  before :each do
    @options = {
      :product => {
        :name => "某某商品",
        :price => 5,
        :summary => "简单说明一下",
        :description => "描述商品",
        :shop_id => shop.id,
        :category_id => category.id,
        :shops_category_id => shops_category.id,
        :default_attachment_id => default_attachment.id,
        :attachment_ids => {
          "test" => attachment.id
        }
      }
    }.merge(current_shop)
  end

  describe "GET 'index'" do
    it "获取所有商品信息" do
      product.valid?.should be_true
      get 'index',current_shop , get_session
      response.should be_success

      assigns(:categories).should_not be_nil
      assigns(:products).should_not be_nil
      assigns(:products).count.should eq(1)
      assigns(:products).should eq([product])
    end
  end

  describe 'GET show' do

    it "获取单个商品信息" do
      get "show", {:id => product.id}.merge(current_shop), get_session

      response.should be_success
      assigns(:product).should eq(product)
      assigns(:product).should_not be_nil
    end
  end

  describe 'GET new ' do

    it "显示商品添加页面" do
      get 'new',current_shop , get_session
      response.should be_success
      response.should render_template(:new)
      assigns(:product).should be_a_new(Product)
    end
  end

  describe 'POST create' do

    it "变动商品信息" do
      expect{
        post :create, @options, get_session
      }.to change(Product, :count).by(1)
    end

    it "添加商品基本信息" do
      post 'create', @options, get_session

      response.should be_success
      response.should render_template(:show)
      attachment_ids = @options[:product].delete(:attachment_ids)
      @options[:product].each{|k, v| assigns(:product).send(k).should eq(v) }
      attachment_ids.map{|k, v| v}.should eq(assigns(:product).attachment_ids)
    end

    it "添加商品信息不完整" do
      @options[:product].delete(:name)
      post 'create', @options, get_session

      response.should be_success
      response.should render_template(:edit)
    end

    it "附加商品属性" do
      @options[:product][:category_id] = 72
      @options[:product].merge!({
        color: 0xFF0000,
        make_in: 'China',
        flavor: 'fragrancy'
      })

      post 'create', @options, get_session
      assigns(:product).make_in.should eql('China')
      assigns(:product).color.should eql(0xFF0000)
      assigns(:product).flavor.should eql('fragrancy')
      response.should be_success
    end


  end

  describe "GET edit" do

    it "显示商品编辑页面" do
      get "edit", {:id => product.id}.merge(current_shop), get_session

      response.should be_success
      response.should render_template(:edit)
      assigns(:product).should eq(product)
    end
  end

  describe "POST update" do

    it "更新商品信息" do
      options = {
        :id => product.id,
        :product => {
          :name => "某某衣服"
        }
      }.merge(current_shop)

      post "update", options, get_session
      response.should be_success
      response.should render_template(:show)
      assigns(:product).name.should eq(options[:product][:name])
    end

    it "更新无效商品信息" do
      options = {
        :id => product.id,
        :product => {
          :name => ""
        }
      }.merge(current_shop)

      post "update", options, get_session
      response.should be_success
      response.should render_template(:edit)
      assigns(:product).valid?.should be_false
    end

    it "调整附加属性 集合" do
      @options[:product][:category_id] = 72
      @options[:product].merge!({
        color: 0xFF0000,
        make_in: 'China',
        flavor: 'fragrancy',
        colour: ["red", "yellow", "green", "blue", "black"],
        sizes: ["S", "M", "XXL", "XL"]
      })

      post 'create', @options, get_session
      assigns(:product).make_in.should eql('China')
      assigns(:product).color.should eql(0xFF0000)
      assigns(:product).flavor.should eql('fragrancy')
      response.should be_success
    end
  end

  describe "DELETE destroy" do

    it "删除商品信息" do
      delete "destroy", {:id => product.id}.merge(current_shop), get_session
      response.should be_success
      response.body.should eq("ok")
    end
  end

  describe "GET accept_product" do

    it "修改商品分类" do
      kuzhi = FactoryGirl.create(:kuzhi, :shop => shop)
      options = {
        :product_id => product.id,
        :shops_category_id => kuzhi.id
      }.merge(current_shop)

      get "accept_product", options, get_session
      response.should be_success
      assigns(:product).shops_category.id.should eq(kuzhi.id)
    end
  end

  describe "get products_by_category" do

    it "获取分类商品" do
      get "products_by_category", {:shops_category_id => shops_category.id}.merge(current_shop), get_session
      response.should be_success
      assigns(:products).each{ | p | p.shops_category.id.should eq(shops_category.id) } if assigns(:products) != nil
    end
  end

end
