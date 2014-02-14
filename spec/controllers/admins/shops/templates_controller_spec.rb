#encoding: utf-8
require 'spec_helper'

describe Admins::Shops::TemplatesController, "模板信息控制器" do

  let(:current_shop){ FactoryGirl.create(:shop, :user => current_user) }

  let(:template) {
    # Template.setup(current_shop)
    Template.find("test", current_shop)
  }

  def shop_attributes
    { :shop_id => current_shop.name }
  end

  def template_attributes(template = nil, form_hash = nil)
    attributes_hash = shop_attributes
    attributes_hash.merge!({:id => template.name}) unless template.nil?
    attributes_hash.merge!(form_hash) unless form_hash.nil?
    attributes_hash
  end

  describe "GET new " do
    it "显示添加" do
      get :new, template_attributes, get_session
      response.should be_success
      assigns(:template).should be_a_new(Template)
    end
  end

  describe "GET index" do
    it "查看所有" do
      get :index, template_attributes, get_session
      response.should be_success
      assigns(:templates).should_not be_nil
      assigns(:templates).select{|t| t.should be_a_instance_of(Vfs::UniversalEntry) }
    end
  end

  describe "GET edit" do
    it "显示编辑" do
      get :edit, template_attributes.merge({:id => ""}) ,get_session
      response.should be_success
      assigns(:template).should be_a_instance_of(Template)
    end
  end

  describe "PUT update" do


    it "修改" do
      form_hash = { template: { data: "asss" } }
      put :update, template_attributes(template, form_hash), get_session
      response.should be_success
      assigns(:template).data.should == form_hash[:template][:data]
    end
  end

end
