require "spec_helper"

describe SystemsController do
  describe "routing" do

    it "routes to #index" do
      get("/systems").should route_to("systems#index")
    end

    it "routes to #new" do
      get("/systems/new").should route_to("systems#new")
    end

    it "routes to #show" do
      get("/systems/1").should route_to("systems#show", :id => "1")
    end

    it "routes to #edit" do
      get("/systems/1/edit").should route_to("systems#edit", :id => "1")
    end

    it "routes to #create" do
      post("/systems").should route_to("systems#create")
    end

    it "routes to #update" do
      put("/systems/1").should route_to("systems#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/systems/1").should route_to("systems#destroy", :id => "1")
    end

  end
end
