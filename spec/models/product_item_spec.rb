#encoding: utf-8
require 'spec_helper'

describe ProductItem, "购物车 商品 " do

  	describe "关联检查" do 
	    it { should belong_to(:cart) }
	    it { should belong_to(:product) }
	    it { should belong_to(:transaction).class_name("OrderTransaction") } 
    end
    
    describe "属性验证" do 
    	let(:product_item) { ProductItem.new }
	    it { product_item.should respond_to(:amount) }
	    it { product_item.should respond_to(:price) }
	    it { product_item.should respond_to(:product_id) }
	    it { product_item.should respond_to(:title) }
	    it { product_item.should respond_to(:total) }
	    it { product_item.should respond_to(:transaction_id) }
	    it { product_item.should respond_to(:cart_id) } 
    end
    
end
