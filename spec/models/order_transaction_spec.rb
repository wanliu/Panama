#encoding: utf-8
require 'spec_helper'

describe OrderTransaction, "订单流通记录" do

	it{ should have_one(:address) }
	it{ should belong_to(:seller) }
	it{ should belong_to(:buyer) }
	it{ should have_many(:items) }

	it{ should validate_presence_of(:buyer) }
	it{ should validate_presence_of(:seller) }
end
