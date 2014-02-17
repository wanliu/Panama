#encoding: utf-8

require "spec_helper"

describe Admins::Shops::OrderRefundsController, "商店退货管理" do

  let(:ems){ FactoryGirl.create(:ems) }
  let(:cbc){ FactoryGirl.create(:cbc) }
  let(:shop_a) { FactoryGirl.create(:shop, user: current_user) }
  let(:category_a) { FactoryGirl.create(:category) }
  let(:category_b) { FactoryGirl.create(:category) }
  let(:shops_category_a) { FactoryGirl.create(:shops_category, shop: shop_a) }
  let(:shops_category_b) { FactoryGirl.create(:shops_category, shop: shop_a) }
  let(:product_i) { FactoryGirl.create(:product, shop: shop_a, category: category_a, shops_category: shops_category_a) }
  let(:product_ii) { FactoryGirl.create(:product, shop: shop_a, category: category_b, shops_category: shops_category_b) }
  let(:item_1) { FactoryGirl.create(:product_item, product: product_i, cart: nil) }
  let(:item_2) { FactoryGirl.create(:product_item, product: product_ii, cart: nil) }
  let(:icbc){ FactoryGirl.create(:icbc) }
  let(:order_reason){ FactoryGirl.create(:order_reason) }
  let(:delivery_manner){ FactoryGirl.create(:express) }
  let(:pay_manner){ FactoryGirl.create(:online_payment) }

  def generate_order
    item_1.cart = my_cart
    item_2.cart = my_cart

    item_1.save
    item_2.save

    my_cart.create_transaction(anonymous)
    OrderTransaction.last
  end

  def generate_refund(order, items)
    refund = order.refunds.create(
      :descripton => '退货',
      :order_reason_id => order_reason.id)
    refund.create_items(items)
    refund
  end

  def request_opt
    {shop_id: shop_a.name}
  end

  describe "GET index" do
    before do
      order = generate_order
      @refund1 = generate_refund(order, [order.items[0].id])
      sleep 1
      @refund2 = generate_refund(order, [order.items[1].id])
    end

    it "获取所有退货单" do
      get :index, request_opt, get_session
      assigns(:refunds).should eq([@refund2, @refund1])
    end
  end

  # describe "GET show" do

  #   before do
  #     order = generate_order
  #     @refund = generate_refund(order, order.items.map{|i| i.id})
  #   end

  #   it "获取某个退货单" do
  #     get :show, request_opt.merge(
  #       :id => @refund.id), get_session
  #     assigns(:refund).should eq(@refund)
  #   end
  # end

  describe "POST event" do

    def refund_order
      order = generate_order
      order.address = current_user_address
      order.delivery_type = ems
      order.pay_manner = pay_manner
      order.delivery_manner = delivery_manner
      order.buyer_fire_event!(:buy)
      order.buyer.recharge(order.stotal, cbc)
      order.buyer_fire_event!(:paid)
      order
    end

    before do
      @order = refund_order
    end

    describe "订单还没发货，退货" do
      before do
        @refund = generate_refund(@order, @order.items.map{|i| i.id})
        @options = request_opt.merge(:id => @refund.id)
      end

      it "申请退货 到 成功" do
        @refund.state.should eq("apply_refund")
        post :event, @options.merge(
          :event => :unshipped_agree), get_session
        assigns(:refund).state.should eq("complete")
      end
    end

    describe "订单已经发货，退货" do
      before do
        @order.delivery_code = '897546444'
        @order.seller_fire_event!(:delivered)
        @refund = generate_refund(@order, @order.items.map{|i| i.id})
        @options = request_opt.merge(:id => @refund.id)
      end

      it "申请退货 到 等待发货" do
        @refund.state.should eq("apply_refund")
        post :event, @options.merge(
          :event => :shipped_agree), get_session
        assigns(:refund).state.should eq("waiting_delivery")
      end

      describe do
        before do
          @refund.delivery_code = "89734546"
          @refund.seller_fire_events!(:shipped_agree)
          @refund.buyer_fire_events!(:delivered)
        end

        it "等待签收 到 完成" do
          @refund.state.should eq("waiting_sign")
          post :event, @options.merge(
            :event => :sign), get_session
          assigns(:refund).state.should eq("complete")
        end
      end
    end
  end

  describe "POST refuse_reason" do
    before do
      order = generate_order
      @refund = generate_refund(order, [order.items[0].id])
    end

    it "拒绝理由" do
      xhr :post, :refuse_reason, request_opt.merge(
        :refuse_reason => "这是人为问题！",
        :id => @refund.id), get_session
      @refund.refuse_reason = "这是人为问题！"
      assigns(:refund).should eq(@refund)
    end
  end
end