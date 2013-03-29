# encoding: utf-8
require 'spec_helper'

describe CategoryController do

  let(:category_root) { Category.where(:name => '_products_root').first }

  describe "必须要登陆才能访问" do
    it "首页" do
      get :index, {}, get_session
      assigns(:category).should eql(category_root)
    end

    let(:test_category) { category_root.children.create(name: 'test_category') }

    it "指定的分类页" do

      get :show, { id: test_category.id }, get_session
      assigns(:category).should eql(test_category)
    end
  end

  describe "未登陆不能访问" do
    it "首页" do
      get :index, {}
      assigns(:category).should be_nil
    end

    it "指定的分类页" do
      get :show, {:id => ""}
      assigns(:category).should be_nil
    end
  end
end
