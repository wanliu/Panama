require "spec_helper"

describe SystemController do
  describe "routing" do

    it "routes to #index" do
      get("/system").should route_to("system#index")
    end

    it "routes to #new" do
      get("/system/new").should route_to("system#new")
    end

    it "routes to #show" do
      get("/system/1").should route_to("system#show", :id => "1")
    end

    it "routes to #edit" do
      get("/system/1/edit").should route_to("system#edit", :id => "1")
    end

    it "routes to #create" do
      post("/system").should route_to("system#create")
    end

    it "routes to #update" do
      put("/system/1").should route_to("system#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/system/1").should route_to("system#destroy", :id => "1")
    end

  end
end
