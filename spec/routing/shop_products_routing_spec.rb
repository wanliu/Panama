require "spec_helper"

describe ShopProductsController do
  describe "routing" do

    it "routes to #index" do
      get("/shop_products").should route_to("shop_products#index")
    end

    it "routes to #new" do
      get("/shop_products/new").should route_to("shop_products#new")
    end

    it "routes to #show" do
      get("/shop_products/1").should route_to("shop_products#show", :id => "1")
    end

    it "routes to #edit" do
      get("/shop_products/1/edit").should route_to("shop_products#edit", :id => "1")
    end

    it "routes to #create" do
      post("/shop_products").should route_to("shop_products#create")
    end

    it "routes to #update" do
      put("/shop_products/1").should route_to("shop_products#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/shop_products/1").should route_to("shop_products#destroy", :id => "1")
    end

  end
end
