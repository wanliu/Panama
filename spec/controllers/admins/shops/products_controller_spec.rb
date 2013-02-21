require 'spec_helper'

describe Admins::Shops::ProductsController do

  let(:session) { {user: FactoryGirl.create(:user) }}
  let(:shop){ FactoryGirl.create(:shop) }

  describe "GET 'index'" do
    it "returns http success" do
      debugger
      get 'index', {:shop_id => shop.name}, session
      response.should be_success
      assigns(:categories).should_not be_nil
      assigns(:products).should_not be_nil
    end
  end

  describe 'GET show' do
  end

end
