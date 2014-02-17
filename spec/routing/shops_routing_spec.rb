#encoding: utf-8
require "spec_helper"

describe ShopsController do
  describe "商店路由" do

    def shop_name
      "asdf"
    end

    # it "到 主页面" do
    #   get("/shops").should route_to("shops#index", :key => :name)
    # end

    it "到 添加页面" do
      get("/shops/new").should route_to("shops#new")
    end

    it "到 显示页面" do
      get("/shops/#{shop_name}").should route_to("shops#show", :id => shop_name)
    end

    it "到 编辑页面" do
      get("/shops/#{shop_name}/edit").should route_to("shops#edit", :id => shop_name)
    end

    it "到 创建" do
      post("/shops").should route_to("shops#create")
    end

    it "到 更新" do
      put("/shops/#{shop_name}").should route_to("shops#update", :id => shop_name)
    end

    it "到 删除" do
      delete("/shops/#{shop_name}").should route_to("shops#destroy", :id => shop_name)
    end

  end
end
