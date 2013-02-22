require "spec_helper"

describe People::TransactionsController do
  describe "routing" do

    it "routes to #index" do
      get("/people/transactions").should route_to("people/transactions#index")
    end

    it "routes to #new" do
      get("/people/transactions/new").should route_to("people/transactions#new")
    end

    it "routes to #show" do
      get("/people/transactions/1").should route_to("people/transactions#show", :id => "1")
    end

    it "routes to #edit" do
      get("/people/transactions/1/edit").should route_to("people/transactions#edit", :id => "1")
    end

    it "routes to #create" do
      post("/people/transactions").should route_to("people/transactions#create")
    end

    it "routes to #update" do
      put("/people/transactions/1").should route_to("people/transactions#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/people/transactions/1").should route_to("people/transactions#destroy", :id => "1")
    end

  end
end
