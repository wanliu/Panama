# encoding : utf-8

require 'spec_helper'

describe "样式使用场景" do
  let(:user)     { FactoryGirl.create(:user) }
  let(:shop)     { FactoryGirl.create(:shop, user: user) }
  let(:category) { FactoryGirl.create(:category, shop: shop) }
  let(:product)  { FactoryGirl.create(:product, shop: shop, category: category) }

  it "关联检查" do
    product.should have_many(:styles)
  end

  describe "访问 styles" do
    let(:colour) { product.styles.where(:name => "colour").first_or_create }
    let(:items) { product.styles.where(:name => "items").first_or_create }
    let(:sizes) { product.styles.where(:name => "sizes").first_or_create }

    it "访问产品样式 通过 styles" do
      product.styles.where(:name => 'colour').first_or_create
      product.styles[:colour].should eql(colour)
    end

    it "增加一个颜色值" do
      red = colour.add_colour_item('red', 0xFF0000)
      blue = colour.add_colour_item('blue', [0,255,0])
      colour.items.should include(red, blue)
    end

    it "增加一个 item" do
      up = items.add_item('上衣', 'up')
      items.items.should include(up)
    end

    let(:s) {sizes.add_size_item('S')}

    it "增加一个 size" do
      sizes.items.should include(s)
    end

    it "检索 一个尺寸" do
      sizes.has?('S').should be_true
    end

  end

end