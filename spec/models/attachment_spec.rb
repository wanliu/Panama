#encoding: utf-8
require 'spec_helper'

describe Attachment, "附件模型" do

	let(:attachment){ FactoryGirl.create(:attachment) }

	it "检查属性" do
	   attachment = Attachment.new
	   attachment.should respond_to(:file)
	   attachment.file.should be_an_instance_of(ImageUploader)
	end

	describe "method get_attributes" do
		it "格式化属性" do
			attachment.get_attributes("100x100").should have_key(:url)
			attachment.get_attributes.should have_key(:url)
		end
	end
end
