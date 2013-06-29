#encoding: utf-8

require 'spec_helper'

describe Admins::Shops::TransactionsController, "商家订单交易控制器" do
  let(:valid_session) { get_session }
  let(:ems){ FactoryGirl.create(:ems) }
  let(:cbc){ FactoryGirl.create(:cbc) }
  let(:shop) { FactoryGirl.create(:shop, user: current_user) }
  let(:category_a) { FactoryGirl.create(:category) }
  let(:category_b) { FactoryGirl.create(:category) }
  let(:shops_category_a) { FactoryGirl.create(:shops_category, shop: shop) }
  let(:shops_category_b) { FactoryGirl.create(:shops_category, shop: shop) }
  let(:product_i) { FactoryGirl.create(:product, shop: shop, category: category_a, shops_category: shops_category_a) }
  let(:product_ii) { FactoryGirl.create(:product, shop: shop, category: category_b, shops_category: shops_category_b) }
  let(:item_1) { FactoryGirl.create(:product_item, product: product_i, cart: nil) }
  let(:item_2) { FactoryGirl.create(:product_item, product: product_ii, cart: nil) }

  def generate_order
    item_1.cart = my_cart
    item_2.cart = my_cart

    item_1.save
    item_2.save

    my_cart.create_transaction(anonymous)
    OrderTransaction.last
  end

  def shop_param
    {:shop_id => shop.name}
  end

  describe "GET pending" do
    before do
      @order1 = generate_order
      @order2 = generate_order
    end

    it "待处理" do
      get :pending, shop_param, valid_session
      expect(assigns(:untransactions)).should eq([@order1, @order2])
      expect(assigns(:transactions)).should eq([])
    end

    it "我处理的" do
      current_user.connect
      @order1.operator_create(current_user.id)
      get :pending, shop_param, valid_session
      assigns(:untransactions).should eq([@order2])
      assigns(:transactions).should eq([@order1])
    end
  end
end
