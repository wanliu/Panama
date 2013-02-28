#encoding: utf-8
require 'spec_helper'

describe ProductItem, "购物车 商品 " do

    describe "关联检查" do
      it { should belong_to(:cart) }
      it { should belong_to(:sub_product) }
      it { should belong_to(:transaction).class_name("OrderTransaction") }
    end

    describe "属性验证" do
      let(:product_item) { ProductItem.new }
      it { product_item.should respond_to(:amount) }
      it { product_item.should respond_to(:price) }
      it { product_item.should respond_to(:sub_product) }
      it { product_item.should respond_to(:title) }
      it { product_item.should respond_to(:total) }
      it { product_item.should respond_to(:transaction) }
      it { product_item.should respond_to(:cart_id) }
    end

    describe "实例方法" do
      describe "product" do
        let(:user) { FactoryGirl.create(:user)}
        let(:shop) { FactoryGirl.create(:shop, user: user) }
        let(:category)    { FactoryGirl.create(:category, shop: shop) }
        let(:product)     { FactoryGirl.create(:product, category: category, shop: shop) }
        let(:sub_product) { FactoryGirl.create(:sub_product, product: product) }

        it "返回product" do
          item = ProductItem.new(sub_product_id: sub_product.id)
          item.product.should == product
        end
      end
    end

end
