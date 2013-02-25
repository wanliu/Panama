# encoding: utf-8
require 'spec_helper'

describe Admins::Shops::CategoriesController do
  fixtures :categories
  Shop.slient!

  def options
    {
      'name'    => 'test_category',
      'shop_id' => pepsi.id
    }
  end

  describe "需要管理权才能进入" do
    let(:pepsi) { FactoryGirl.create(:shop,
                                     user: get_session[:user]) }
    let(:root) { pepsi.category }

    it "首页" do
      get :index, { shop_id: pepsi.name }, get_session
      assigns(:categories).should eql(Category.sort_by_ancestry(root.descendants))
      response.should be_success
    end

    it "新分类" do
      parent = root
      indent =  parent.indent
      xhr :get, :new, { shop_id: pepsi.name, parent_id: parent.id }, get_session
      assigns(:category).parent.should eql(parent)
      assigns(:category).indent.should == indent + 1
      response.should be_success
    end

    it "创建分类" do
      parent = root
      indent =  parent.indent

      category = FactoryGirl.build(:category, options)

      xhr :post, :create, { shop_id: pepsi.name,
                            parent_id: parent.id,
                            category: options }, get_session

      parent.children.should include(assigns(:category))
      assigns(:category).name.should == 'test_category'
      assigns(:category).shop_id.should == pepsi.id
      response.should render_template(:edit)
    end

    it "更新分类" do
      node1 = root.children.create(options)
      xhr :put, :update, { shop_id: pepsi.name,
                           id: node1.id,
                           category: {
                             name: 'name_changed',
                           }
                         }, get_session

      assigns(:category).name.should == 'name_changed'
    end

    it "删除分类" do
      node1 = root.children.create(options)
      xhr :post, :destroy, { shop_id: pepsi.name,
                             id: node1.id
                           }, get_session

      root.children.should_not include(node1)
    end

    describe "无效的分类" do

      it "删除非了孙类的分类" do
        node1 = FactoryGirl.create(:category, options)

        expect { xhr :post, :destroy, { shop_id: pepsi.name,
                               id: node1.id
                             }, get_session }.to raise_error(ArgumentError)

      end

      it "分类不能删除自己" do
        node1 = pepsi.category

        expect { xhr :post,
                     :destroy, { shop_id: pepsi.name,
                                 id:      node1.id
                               }, get_session }.to raise_error(ArgumentError)

      end

      it "创建分类的父分类必须属于,当前根节点" do
        parent = FactoryGirl.create(:category, 'name' => 'test_category', :shop => nil)
        indent =  parent.indent

        expect {  xhr :post, :create, { shop_id: pepsi.name,
                              parent_id: parent.id,
                              category: options }, get_session }.to raise_error(ArgumentError)
      end
    end
  end

  describe "无管理权拒绝" do
    let(:pepsi) { FactoryGirl.create(:shop, user: get_session[:user]) }
    let(:root) { pepsi.category }

    it "首页" do
      get :index, { shop_id: pepsi.name }
      response.response_code.should == 302 # redirect
    end

    it "新分类" do
      parent = root
      indent =  parent.indent
      xhr :get, :new, { shop_id: pepsi.name, parent_id: parent.id }
      response.response_code.should == 403 # redirect
    end

    it "创建分类" do
      parent = root
      indent =  parent.indent

      category = FactoryGirl.build(:category, options)

      xhr :post, :create, { shop_id: pepsi.name,
                            parent_id: parent.id,
                            category: options }

      response.response_code.should == 403 # redirect
    end

    it "更新分类" do
      node1 = root.children.create(options)
      xhr :put, :update, { shop_id: pepsi.name,
                           id: node1.id,
                           category: {
                             name: 'name_changed',
                           }
                         }

      response.response_code.should == 403 # redirect
    end

    it "删除分类" do
      node1 = root.children.create(options)
      xhr :post, :destroy, { shop_id: pepsi.name,
                             id: node1.id
                           }

      response.response_code.should == 403 # redirect
    end
  end
end
