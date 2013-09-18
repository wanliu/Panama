#encoding: utf-8
require 'spec_helper'

describe AttachmentsProducts, "附件与商品中间关系" do

	it "检查属性"	 do
		ap = AttachmentsProducts.new
		ap.should respond_to(:attachment_id)
		ap.should respond_to(:product_id)
	end
end
