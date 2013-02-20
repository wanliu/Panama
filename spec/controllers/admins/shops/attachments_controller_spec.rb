require 'spec_helper'

describe Admins::Shops::AttachmentsController do 

    describe "POST upload" do 
        it "request success" do         
            post "upload", {version_name: '100x100', attachable: '4822.jpg'}, {"Content-Type" => "application/octet-stream"}
        end
    end
end