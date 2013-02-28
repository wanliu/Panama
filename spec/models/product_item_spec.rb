#encoding: utf-8
require 'spec_helper'

describe ProductItem, "购物车 商品 " do
 
    def prod_item
		{
			:amount => 11,
			:price => 12345,
			:total =>  123456,
			:product_id => 1,
			:cart_id => 1
		}
	end

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


    describe "模型装饰" do
    	it "模型装饰  price " do
	    	pr = ProductItem.create! prod_item
	    	pr_de = pr.decorate
	    	pr_de.source.price.should eq(pr_de.price.delete(', ¥').to_f) 
	    end

	    it "模型装饰  total " do
	    	pr = ProductItem.create! prod_item
	    	pr_de = pr.decorate
	    	pr_de.source.total.should eq(pr_de.total.delete(', ¥').to_f) 
	    end
    end
end
