#encoding: utf-8
require 'spec_helper'

describe OrderRefund, "退货" do

	let(:order_reason){ FactoryGirl.create(:order_reason)}
	let(:order_transaction){ FactoryGirl.create(:transaction)}
	let(:item_1) { FactoryGirl.create(:product_item, product: product_i, cart: nil) }
	let(:item_2) { FactoryGirl.create(:product_item, product: product_ii, cart: nil) }

    describe "关联检查" do
	  it{ should belong_to(:order_reason) }
	  it{ should belong_to(:order_transaction) }
	  it{ should have_many(:items) }
	end
end
