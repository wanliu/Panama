#encoding: utf-8
require 'spec_helper'

describe Admins::Shops::ProductsController do

  def upload_file
    photo_path = [Rails.root, "public/default_img/file_blank.gif"].join("/")
    ActionDispatch::Http::UploadedFile.new(
        :filename => "a.gif",
        :type => "image/jpeg",
        :tempfile => File.new(photo_path) )
  end

  let(:shop){ FactoryGirl.create(:shop, :user => get_session[:user] ) }
  let(:category){ FactoryGirl.create(:root_category, :shop => shop) }
  let(:product){ FactoryGirl.create(:product, :shop => shop, :category => category) }
  let(:current_shop){ {:shop_id => shop.name} }
  let(:default_attachment){ FactoryGirl.create(:attachment, :file => upload_file) }
  let(:attachment){ FactoryGirl.create(:attachment, :file => upload_file) }

  before :each do
    @options = {
      :product => {
        :name => "某某产品",
        :price => 5,
        :summary => "简单说明一下",
        :description => "描述产品",
        :shop_id => shop.id,
        :category_id => category.id,
        :default_attachment_id => default_attachment.id,
        :attachment_ids => {
          "test" => attachment.id
        }
      }
    }.merge(current_shop)
  end

  describe "GET 'index'" do
    it "获取所有产品信息" do
      product.valid?.should be_true
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
      get "show", {:id => product.id}.merge(current_shop), get_session

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

    it "添加产品基本信息" do
      post 'create', @options, get_session
      response.should be_success
      response.should render_template(:show)
      attachment_ids = @options[:product].delete(:attachment_ids)
      @options[:product].each{|k, v| assigns(:product).send(k).should eq(v) }
      attachment_ids.map{|k, v| v}.should eq(assigns(:product).attachment_ids)
    end

    it "添加产品信息不完整" do
      @options[:product].delete(:name)
      post 'create', @options, get_session
      response.should be_success
      response.should render_template(:edit)
    end
  end

  describe "GET edit" do

    it "显示产品编辑页面" do
      get "edit", {:id => product.id}.merge(current_shop), get_session

      response.should be_success
      response.should render_template(:edit)
      assigns(:product).should eq(product)
    end
  end

  describe "POST update" do

    it "更新产品信息" do
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

    it "更新无效产品信息" do
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
  end

  describe "DELETE destroy" do

    it "删除产品信息" do
      delete "destroy", {:id => product.id}, get_session
      response.should be_success
      response.body.should eq("ok")
    end
  end


end
