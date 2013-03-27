#encoding: utf-8
require 'spec_helper'

describe Admins::Shops::AttachmentsController, "附件控制器" do

    let(:shop){ FactoryGirl.create(:shop, user: current_user) }
    before :each do
        photo_path = Rails.root.join("public/default_img/file_blank.gif")
        @file = ActionDispatch::Http::UploadedFile.new(
            :filename => "a.gif",
            :type => "image/jpeg",
            :tempfile => File.new(photo_path))
    end

    def shop_opt
        {shop_id: shop.name}
    end

    describe "POST upload" do
      it "成功上传图片" do
        xhr :post, "upload", shop_opt.merge({version_name: '100x100', file: @file}), get_session

        response.should be_success
        attachment = assigns[:attachment]
        attachment.should_not be_nil
        attachment.valid?.should be_true
        attachment.file.is_a?(ImageUploader).should be_true
      end

      it "失败上传" do
        xhr :post, "upload", shop_opt.merge({version_name: '100x100'}), get_session
        assigns(:attachment).file.file.should be_nil
      end
    end

    describe "DELETE destroy" do
        it "删除上传图片" do
            a = Attachment.create(:file => @file)
            delete "destroy", shop_opt.merge({:id => a.id}), get_session
            response.should be_success
        end
    end
end