require 'spec_helper'

describe Admins::Shops::AttachmentsController do 
    let(:user){ FactoryGirl.create(:login_user) }

    before :each do         
        request.host = "/shops/asdf/admins/attachments"       
    end  

    describe "POST upload" do 
        it "request success" do                     
            post "upload", {
                version_name: '100x100', 
                attachable: '4822.jpg', 
                shop_id: "asdf"}, {"Content-Type" => "application/octet-stream"}

            response.should be_success
        end
    end
end