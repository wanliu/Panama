require 'spec_helper'

describe Admins::Shops::AttachmentsController do

    describe "POST upload" do
      let(:session) { {user: FactoryGirl.create(:user) }}

      it "request success" do
        post "upload", {version_name: '100x100', attachable: '4822.jpg', shop_id: "asdf"}, session
      end
    end
end