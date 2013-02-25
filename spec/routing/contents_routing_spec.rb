#encoding: utf-8
require "spec_helper"

describe ContentsController do
  describe "模板内容路由" do

    # it "到 主页面" do
    #   get("/contents").should route_to("contents#index")
    # end

    it "到 显示添加信息" do
      get("/contents/new").should route_to("contents#new")
    end

    it "到 浏览" do
      get("/contents/1").should route_to("contents#show", :id => "1")
    end

    it "到 编辑" do
      get("/contents/1/edit").should route_to("contents#edit", :id => "1")
    end

    it "到 添加" do
      post("/contents").should route_to("contents#create")
    end

    it "到 更新" do
      put("/contents/1").should route_to("contents#update", :id => "1")
    end

    it "到 删除" do
      delete("/contents/1").should route_to("contents#destroy", :id => "1")
    end

  end
end
