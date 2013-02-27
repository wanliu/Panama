require 'spec_helper'

describe Admins::Shops::ComplaintController do
  let(:pepsi) { FactoryGirl.create(:shop, user: current_user) }
  let(:valid_shop) {{ shop_id: pepsi.to_param }}

  describe "GET 'index'" do
    it "returns http success" do
      get 'index', valid_shop, get_session
      response.should be_success
    end
  end

end
