#encoding: utf-8
require 'spec_helper'

describe Cart, "model 购物车 " do

	describe "关联检查" do
    it { should belong_to(:user) }
    it { should have_many(:items).class_name('ProductItem') }
  end

  describe "属性验证" do
    it { cart.should respond_to(:items_count) }
    it { cart.should respond_to(:user_id) }
  end

  describe "实例方法" do
  	let(:people) { FactoryGirl.create(:user) }
  	let(:shop_owner) { FactoryGirl.create(:user) }
   	let(:shop_a) { FactoryGirl.create(:shop, user: shop_owner) }
    let(:shop_b) { FactoryGirl.create(:shop, user: shop_owner) }
    let(:category) { FactoryGirl.create(:category, shop: shop_a) }
    let(:product_i) { FactoryGirl.create(:product, shop: shop_a, category: category) }
    let(:product_ii) { FactoryGirl.create(:product, shop: shop_b, category: category) }
    let(:product_iii) { FactoryGirl.create(:product, shop: shop_b, category: category) }
    let(:product_iv) { FactoryGirl.create(:product, shop: shop_a, category: category) }
    let(:item_1) { FactoryGirl.create(:product_item, product: product_i, cart: nil, transaction: nil) }
    let(:item_2) { FactoryGirl.create(:product_item, product: product_ii, cart: nil, transaction: nil) }
    let(:item_3) { FactoryGirl.create(:product_item, product: product_iii, cart: nil, transaction: nil) }
    let(:item_4) { FactoryGirl.create(:product_item, product: product_iv, cart: nil, transaction: nil) }
    let(:item_5) { FactoryGirl.create(:product_item, product: product_i, cart: nil, transaction: nil) }
    let(:item_6) { FactoryGirl.create(:product_item, product: product_iii, cart: nil, transaction: nil) }
    let(:the_items) { [item_1, item_2, item_3, item_4, item_5, item_6].map { |item| item.attributes } }

    describe "create_transaction" do
  		it "ok" do
  			cart = Cart.new
	  		the_items.each { |item| cart.items << ProductItem.create(item) }

	  		done = cart.shop_items.each { |shop, items| cart.should_receive(:save_transcation)
	  																						        .exactly(1).times
	  																						        .with(shop, items, people) }
	  		cart.create_transaction(people)
	  		done.should be_true
	  	end
  	end

  	describe "save_transcation" do
  		it 'change the transactions size' do
  			cart = Cart.new
  			people = User.where(login: 'tt_name1').first_or_create
  			expect { cart.save_transcation(shop_a, the_items, people) }
  				.to change { people.transactions.size }.by(1)
  		end

  		it 'invoke the transactions instance method' do
        cart = Cart.new
        people = User.where(login: 'tt_name1'). first_or_create

  			OrderTransaction.any_instance.should_receive(:create_items).with(the_items).exactly(1).times
        OrderTransaction.any_instance.should_receive(:update_total_count).exactly(1).times
        cart.save_transcation(shop_a, the_items, people)
  		end
  	end
  end

end
