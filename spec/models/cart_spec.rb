#encoding: utf-8
require 'spec_helper'

describe Cart, "model 购物车 " do

	describe "关联检查" do
    it { should belong_to(:user) }
    it { should have_many(:items).class_name('ProductItem') }
  end

  describe "属性验证" do
    let(:cart) { Cart.new }
    it { cart.should respond_to(:items_count) }
    it { cart.should respond_to(:user_id) }
  end

  describe "实例方法" do
  	let(:people)     { FactoryGirl.create(:user) }
  	let(:shop_owner) { FactoryGirl.create(:user) }
   	let(:shop_a) { FactoryGirl.create(:shop, user: shop_owner) }
    let(:shop_b) { FactoryGirl.create(:shop, user: shop_owner) }
    let(:shop_c) { FactoryGirl.create(:shop, user: shop_owner) }
    let(:category_a) { FactoryGirl.create(:category) }
    let(:category_b) { FactoryGirl.create(:category) }
    let(:category_c) { FactoryGirl.create(:category) }
    let(:category_d) { FactoryGirl.create(:category) }
    let(:shops_category_a) { FactoryGirl.create(:shops_category, shop: shop_a) }
    let(:shops_category_b) { FactoryGirl.create(:shops_category, shop: shop_b) }
    let(:shops_category_c) { FactoryGirl.create(:shops_category, shop: shop_c) }
    let(:shops_category_d) { FactoryGirl.create(:shops_category, shop: shop_b) }
    let(:product_i) { FactoryGirl.create(:product, shop: shop_a, category: category_a, shops_category: shops_category_a) }
    let(:product_ii) { FactoryGirl.create(:product, shop: shop_b, category: category_b, shops_category: shops_category_b) }
    let(:product_iii) { FactoryGirl.create(:product, shop: shop_b, category: category_d, shops_category: shops_category_d) }
    let(:product_iv)  { FactoryGirl.create(:product, shop: shop_c, category: category_c, shops_category: shops_category_c) }
    # let(:sub_product_i) { FactoryGirl.create(:sub_product, product: product_i) }
    # let(:sub_product_ii) { FactoryGirl.create(:sub_product, product: product_ii) }
    # let(:sub_product_iii) { FactoryGirl.create(:sub_product, product: product_iii) }
    # let(:sub_product_iv)  { FactoryGirl.create(:sub_product, product: product_iv) }
    let(:item_1) { FactoryGirl.create(:product_item, product: product_i, cart: nil, transaction: nil) }
    let(:item_2) { FactoryGirl.create(:product_item, product: product_ii, cart: nil, transaction: nil) }
    let(:item_3) { FactoryGirl.create(:product_item, product: product_iii, cart: nil, transaction: nil) }
    let(:item_4) { FactoryGirl.create(:product_item, product: product_iv, cart: nil, transaction: nil) }
    let(:item_5) { FactoryGirl.create(:product_item, product: product_i, cart: nil, transaction: nil) }
    let(:item_6) { FactoryGirl.create(:product_item, product: product_iii, cart: nil, transaction: nil) }
    # let(:the_items) { [item_1, item_2, item_3, item_4, item_5, item_6].map { |item| item.attributes } }
    let(:the_items) { [item_1, item_2, item_3, item_4, item_5, item_6] }

    describe "create_transaction" do
  		it "按商店分单" do
  			cart = Cart.new
	  		# the_items.each { |item| cart.items << ProductItem.create(item) }

	  		done = cart.shop_items.each { |shop, items| cart.should_receive(:save_transcation)
	  																						        .exactly(1).times
	  																						        .with(shop, items, people) }
	  		cart.create_transaction(people)
	  		done.should be_true
	  	end
  	end

  	describe "save_transcation" do
      let(:cart) { Cart.new(items_count: 0, total: 0) }
      let(:people) { User.where(login: 'tt_name').first_or_create }

      it '数据库增一个订单' do
        expect { cart.save_transcation(shop_a, the_items, people) }.to change { people.transactions.size }.by(1)
      end

  		it '调用订单成员方法' do
        uer = mock_model("User")

        ordertransaction = mock_model("OrderTransaction")
        uer.stub_chain(:transactions, :build).with(seller_id: shop_a.id).and_return(ordertransaction)

  			# ordertransaction.should_receive(:build_items).with(the_items).exactly(1).times
        # ordertransaction.should_receive(:update_total_count).exactly(1).times
        ordertransaction.should_receive("items=").with(the_items).exactly(1).times
        ordertransaction.should_receive(:save).exactly(1).times        
        cart.save_transcation(shop_a, the_items, uer)
  		end
  	end
  end

end
