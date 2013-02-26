#encoding: utf-8
require 'spec_helper'

describe SubProduct do

  describe "混合赋值" do
    it ("quantity") { should allow_mass_assignment_of(:quantity) }
    it ("price")    { should allow_mass_assignment_of(:price) }
  end

  describe "关联测试" do
  	it ("belongs_to :product")   { should belong_to(:product) }
  	it ("has_many :style_pairs") { should have_many(:style_pairs) }
  	it ("has_many :style_items") { should have_many(:items).through(:style_pairs) }
  end

  describe "validates：验证测试" do
    it ("product_id存在") { should validate_presence_of(:product_id) }
    it ("price存在")      { should validate_presence_of(:price) }
    it ("price数字")      { should validate_numericality_of(:price) }
    it ("quanity存在")    { should validate_presence_of(:quantity) }
    it ("quantity数字")   { should validate_numericality_of(:quantity) }
  end

  describe "实例方法" do
    let(:user)     { FactoryGirl.create(:user) }
    let(:shop)     { FactoryGirl.create(:shop, user: user) }
    let(:category) { FactoryGirl.create(:category, shop: shop) }
    let(:product)  { FactoryGirl.create(:product, shop: shop, category: category) }
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