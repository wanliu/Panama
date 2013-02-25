#encoding: utf-8
require 'spec_helper'

describe OrderTransaction, "订单流通记录" do

	it{ should have_one(:address) }
	it{ should belong_to(:seller) }
	it{ should belong_to(:buyer) }
	it{ should have_many(:items) }

	it{ should validate_presence_of(:buyer) }
	it{ should validate_presence_of(:seller) }

	it "检查属性" do
		transaction = OrderTransaction.new
		transaction.should response_to(:items_count)
		transaction.should response_to(:total)
		transaction.should response_to(:state)
	end

	it "数据验证" do

	end
end
