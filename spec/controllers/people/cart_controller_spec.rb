#encoding: utf-8
require 'spec_helper' 

describe People::CartController do

	def product_item
		{ 
			:title =>  "1111",
			:amount => 11,
			:price => 11,
			:total =>  111,
			:product_id => '1',
			:cart_id => '1'
		}
	end
 
	describe "post 'add_to_cart' 购物车  增加" do
		let(:session_obj) { get_session }
		let(:user) { session_obj[:user] }
		let(:my_cart) { user.cart }

		it "add cart product_item" do
			get 'index', {:page => 1}, session_obj 
			assigns(:items) 
		end

		it "add cart product_item" do
			post 'add_to_cart', {:product_item => product_item }, session_obj
			item = product_item
			assigns(:item).total.should eq((item[:amount] * item[:price]))
		end

		it "updat product_item amount" do
			my_cart.items.create! product_item
			item = product_item
			item[:cart_id] = my_cart.id
			post 'add_to_cart', {:product_item => item }, session_obj
			item = product_item
			assigns(:item).amount.should eq((item[:amount] + item[:amount]))
		end

		it "add cart product_item updat product_item amount" do
			my_cart.items.create! product_item
			my_cart.items.create! product_item  
			post 'clear_list',{}, session_obj 
			my_cart.items.length.should eq(0)
		end
	end

end
