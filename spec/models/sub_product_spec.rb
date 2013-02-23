#encoding: utf-8
require 'spec_helper'

describe SubProduct do
  let(:user)    { FactoryGirl.create(:user) }
  let(:shop)    { FactoryGirl.create(:shop, user: user) }
  let(:category) { FactoryGirl.create(:category, shop: shop) }
  let(:product)  { FactoryGirl.create(:product, shop: shop, category: category) }

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
    let(:sub)         { FactoryGirl.create(:sub_product, product: product) }
    let(:style_group) {FactoryGirl.create(:style_group, product: product)}
    let(:item)        {FactoryGirl.create(:style_item, style_group: style_group)}
    it "styles" do
      expect = { price: sub.price, quantity: sub.quantity }
      expect[style_group['name'].to_sym] = item.title

      sub.items << item
      sub.styles.should == expect
    end
  end
end
