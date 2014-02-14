#encoding: utf-8
require 'spec_helper'

describe People::CartController do

	def product_item
		{
			:title =>  "1111",
			:amount => 11,
			:price => 11,
			:total =>  111,
			:product_id => '10001',
		}
	end

	def form_params(form_attributes = {})
		{
			person_id: current_user.login,
			product_item: form_attributes
		}
	end

	let(:my_cart) { current_user.cart }

	describe " 购物车 " do
		describe " get 'index' " do
			it "add cart product_item" do
				item = my_cart.items.create! product_item
				get 'index', {:person_id => "", :page => 1}, get_session
				assigns(:items).should eq([item])
			end
		end

		describe "post 'add_to_cart' 购物车  增加" do
			it "add cart product_item" do
				post 'add_to_cart', form_params(product_item), get_session
				item = product_item
				assigns(:item).total.should eq((item[:amount] * item[:price]))
			end

			it "updat product_item amount" do
				my_cart.items.create! product_item
				item = product_item
				item[:cart_id] = my_cart.id
				post 'add_to_cart', form_params(item).merge({:id => ""}), get_session
				item = product_item
				assigns(:item).amount.should eq((item[:amount] + item[:amount]))
			end
		end

		describe "post 'clear_list' 购物车 册除" do
			it "clear_list" do
				my_cart.items.create! product_item
				post 'clear_list', form_params.merge({:id => ""}), get_session
				my_cart.should have(0).items
			end
		end

		let(:apple) { Product.find(product_item[:product_id]) }
		let(:colour) { Property.find_by_name("colour") }
		let(:sizes) { Property.find_by_name("sizes") }

		describe "附加属性来购物" do
			it "选择 红色大码" do
				apple.properties << colour
				apple.properties << sizes
				apple.price_options.create(property: colour)
				apple.price_options.create(property: sizes)

				_prod_item = product_item.merge sizes: "L", colour: "red"

				post 'add_to_cart', form_params(_prod_item), get_session
				assigns(:item).sizes.should eql "L"
				assigns(:item).colour.should eql "red"
		  end
		end
	end

end
