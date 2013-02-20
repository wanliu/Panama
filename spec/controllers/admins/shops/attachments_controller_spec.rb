#encoding: utf-8
require 'spec_helper'

describe Admins::Shops::AttachmentsController do
    let(:session) { {user: FactoryGirl.create(:user) }}

    before :each do
        photo_path = [Rails.root, "public/default_img/file_blank.gif"].join("/")
        @file = ActionDispatch::Http::UploadedFile.new(
            :filename => "a.gif",
            :type => "image/jpeg",
            :tempfile => File.new(photo_path) )
    end

    describe "POST upload" do
      it "成功上传图片" do
        post "upload", {version_name: '100x100', file: @file}, session
        response.should be_success
        attachment = assigns[:attachment]
        attachment.should_not be_nil
        attachment.valid?.should be_true
        attachment.file.is_a?(ImageUploader).should be_true
      end
    end

    describe "DELETE destroy" do
        it "删除上传图片" do
            a = Attachment.create(:file => @file)
            delete "destroy", {:id => a}, session
            response.should be_success
        end
    end
end