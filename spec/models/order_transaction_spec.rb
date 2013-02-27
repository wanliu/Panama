#encoding: utf-8
require 'spec_helper'

describe OrderTransaction, "订单流通记录" do

    let(:shop){ FactoryGirl.create(:shop, :user => FactoryGirl.create(:user)) }

    it{ should have_one(:address) }
    it{ should belong_to(:seller) }
    it{ should belong_to(:buyer) }
    it{ should have_many(:items) }

    it{ should validate_presence_of(:buyer) }
    it{ should validate_presence_of(:seller_id) }
    it{ should validate_numericality_of(:items_count) }
    it{ should validate_numericality_of(:total) }

    def params
        {
          :buyer_id => anonymous.id,
          :items_count => 2,
          :seller_id => shop.id,
          :total => 5,
          :address_id => 3
        }
    end

    it "检查属性" do
        transaction = OrderTransaction.new
        transaction.should respond_to(:items_count)
        transaction.should respond_to(:total)
        transaction.should respond_to(:state)
    end

    it "数据验证" do
        transaction = OrderTransaction.new(params)
        transaction.save.should be_true

        transaction.buyer_id = nil
        transaction.save.should be_false

        transaction.buyer_id = anonymous.id
        transaction.save.should be_true

        transaction.items_count = "a"
        transaction.save.should be_false

        transaction.items_count = params[:items_count]
        transaction.save.should be_true

        transaction.total = "a"
        transaction.save.should be_false

        transaction.total = params[:total]
        transaction.save.should be_true
    end

    it "状态" do
        o = OrderTransaction.new(params)
        o.save.should be_true
        o.state.should eq("order")
        o.buy.should be_true
        o.state.should eq("waiting_paid")
        o.back.should be_true
        o.state.should eq("order")
    end
end
