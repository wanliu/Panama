require "spec_helper"

describe People::TransactionsController do
  describe "routing" do

    it "routes to #index" do
      get("/people/hysios/transactions").should route_to("people/transactions#index", :person_id => 'hysios')
    end

    it "routes to #new" do
      get("/people/hysios/transactions/new").should route_to("people/transactions#new", :person_id => 'hysios')
    end

    it "routes to #show" do
      get("/people/hysios/transactions/1").should route_to("people/transactions#show", :id => "1", :person_id => 'hysios')
    end

    it "routes to #edit" do
      get("/people/hysios/transactions/1/edit").should route_to("people/transactions#edit", :id => "1", :person_id => 'hysios')
    end

    it "routes to #create" do
      post("/people/hysios/transactions").should route_to("people/transactions#create", :person_id => 'hysios')
    end

    it "routes to #update" do
      put("/people/hysios/transactions/1").should route_to("people/transactions#update", :id => "1", :person_id => 'hysios')
    end

    it "routes to #destroy" do
      delete("/people/hysios/transactions/1").should route_to("people/transactions#destroy", :id => "1", :person_id => 'hysios')
    end

  end
end
