# encoding : utf-8
require 'spec_helper'

describe StyleItem do
  let(:user)        { FactoryGirl.create(:user) }
  let(:shop)        { FactoryGirl.create(:shop, user: user) }
  let(:category)    { FactoryGirl.create(:category, shop: shop) }
  let(:product)     { FactoryGirl.create(:product, shop: shop, category: category) }
  let(:style_group) { FactoryGirl.create(:style_group, product: product) }

  describe "关联测试" do
    it "belongs_to :style_group" do
      should belong_to(:style_group)
    end

    it "has_many :style_pairs" do
      should have_many(:style_pairs)
    end

    it "has_many :sub_products, through :style_pairs" do
      should have_many(:sub_products).through(:style_pairs)
    end
  end

  describe "validates 验证测试" do
    it "正常情况,验证通过" do
      style_group.items.where(title: 't_title1', value: 't_value1').first_or_create
      item = style_group.items.build(title: 't_title2', value: 't_value2')
      item.should be_valid
    end

    it "同一个scope：style_group下的items的 title 的值唯一" do
      style_group.items.where(title: 't_2title', value: 't_2value1').first_or_create
      item = style_group.items.build(title: 't_2title', value: 't_2value2')
      item.valid?
      item.should have(1).error_on(:title)
    end

    it "同一个scope：style_group下的items的 value 的值唯一" do
      style_group.items.where(title: 't_3title1', value: 't_3value').first_or_create
      item = style_group.items.build(title: 't_3title2', value: 't_3value')
      item.valid?
      item.should have(1).error_on(:value)
    end

    it "style_group_id 不能为空" do
      item = StyleItem.new(title: 'title_test', value: 'value_test')
      item.valid?
      item.should have(1).error_on(:style_group_id)
    end

  end
end
