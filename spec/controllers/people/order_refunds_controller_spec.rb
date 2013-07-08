#encoding: utf-8
require "spec_helper"

describe People::OrderRefundsController, "个人订单退货" do
  let(:ems){ FactoryGirl.create(:ems) }
  let(:cbc){ FactoryGirl.create(:cbc) }
  let(:shop_a) { FactoryGirl.create(:shop, user: anonymous) }
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

    my_cart.create_transaction(current_user)
    OrderTransaction.last
  end

  def request_opt
    { :person_id => current_user.login }
  end

  def generate_refund(order, items)
    refund = order.refunds.create(
      :descripton => '退货',
      :order_reason_id => order_reason.id)
    refund.create_items(items)
    refund
  end

  describe "GET index" do
    before do
      order = generate_order
      @refund1 = generate_refund(order, [order.items.first.id])
      sleep 1
      @refund2 = generate_refund(order, [order.items.last.id])
    end

    it "获取自己所有退货" do
      get :index, request_opt, get_session
      assigns(:refunds).should eq([@refund2, @refund1])
    end

  end

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
      @refund1 = generate_refund(@order, @order.items.map{|i| i.id})
      @options = request_opt.merge(:id => @refund1.id)
    end

    describe "订单已经发货" do
      before do
        @order.delivery_code = "8797879895646"
        @order.seller_fire_event!(:delivered)
        @refund1.order_transaction.reload
        @refund1.seller_fire_events!(:shipped_agree)
      end

      it "退货发货" do
        @refund1.state.should eq("waiting_delivery")
        post :event, @options.merge(
          :event => :delivered), get_session
        assigns(:refund).state.should eq("waiting_sign")
      end
    end
  end

  describe "POST delivery_code" do
    before do
      @order = generate_order
      @refund1 = generate_refund(@order, @order.items.map{|i| i.id})
    end

    it "填写快递编号" do
      xhr :post, :delivery_code, request_opt.merge(
        :id => @refund1.id,
        :delivery_code => "789764654"), get_session
      @refund1.delivery_code = "789764654"
      assigns(:refund).should eq(@refund1)
    end
  end
end