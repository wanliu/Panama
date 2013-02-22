#encoding: utf-8
require 'spec_helper'

describe SubProduct do
  let(:category) { Category.root }
  let(:shop) { Shop.where(name: 'shop_for_style_items').first_or_create }
  let(:product) { Product.where(name: 'iphone4s',
                                price: 5999,
                                category_id: category.id,
                                shop_id: shop.id).first_or_create }

  let(:style_group) { StyleGroup.where(name: 't_groups',
                                       product_id: product.id).first_or_create }

  describe "关联测试" do
  	it "belongs_to :product" do
  		should belong_to(:product)
  	end

  	it "has_many :style_pairs" do
  		should have_many(:style_pairs)
  	end

  	it "has_many :style_items, through :style_pairs" do
  		should have_many(:items).through(:style_pairs)
  	end
  end

  # describe "validates：验证测试" do
  # end

  describe "方法" do
    it "styles" do
      sub = product.sub_products.create(price: 10, quantity: 10)

      item1 = StyleItem.where(title: 'say_title',
                              value: 'say_value',
                              style_group_id: style_group.id).first_or_create
      sub.items << item1

      sub.styles.should be_eql(t_group: 'say_title', price: 10.to_f, quantity: 10.to_f)
    end
  end
end
