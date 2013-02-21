# encoding: utf-8
require 'spec_helper'

describe Admins::Shops::CategoriesController do

  describe "需要管理权才能进入" do
    let(:pepsi) { FactoryGirl.create(:shop, user: get_session[:user]) }
    let(:root) { pepsi.category }

    it "首页" do
      get :index, { shop_id: pepsi.name }, get_session
      assigns(:categories).should eql(Category.sort_by_ancestry(root.descendants))
    end
  end

  describe "无管理权拒绝" do
    let(:pepsi) { FactoryGirl.create(:shop, user: get_session[:user]) }
    let(:root) { pepsi.category }

    it "首页" do
      get :index, { shop_id: pepsi.name }
      response
      assigns(:categories).should eql(Category.sort_by_ancestry(root.descendants))
    end
  end
end
