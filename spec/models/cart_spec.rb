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
  	describe "create_transaction" do
  		
  	end
  	describe "shop_items" do
  		
  	end
  	describe "save_transcation" do
  		
  	end
  end

end
