#encoding: utf-8
require 'spec_helper'

describe SubProduct do
  let(:product)     { FactoryGirl.create(:product) }

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
      sub = FactoryGirl.create(:sub_product)
      style_group = FactoryGirl.create(:style_group)
      item = style_group.items.where(title: 't_title', value: 't_value').first_or_create

      expect = { price: sub.price, quantity: sub.quantity }
      expect[style_group['name'].to_sym] = item.title

      sub.items << item

      sub.styles.should == expect
    end
  end
end
