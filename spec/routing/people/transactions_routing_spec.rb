#encoding: utf-8
require "spec_helper"

describe People::TransactionsController, "用户订单交易流通" do
  describe "路由" do

    def params
      {
        :person_id => "lishi"
      }
    end

    def one_params
      params.merge({:id => "1"})
    end

    it "获取所有记录" do
      get("/people/lishi/transactions").should route_to("people/transactions#index", params)
    end

    it "显示添加页面" do
      get("/people/lishi/transactions/new").should route_to("people/transactions#new", params)
    end

    it "显示一条记录页面" do
      get("/people/lishi/transactions/1").should route_to("people/transactions#show", one_params)
    end

    it "添加" do
      post("/people/lishi/transactions").should route_to("people/transactions#create", params)
    end

    it "更改" do
      put("/people/lishi/transactions/1").should route_to("people/transactions#update", one_params)
    end

    it "删除" do
      delete("/people/lishi/transactions/1").should route_to("people/transactions#destroy", one_params)
    end

  end
end
