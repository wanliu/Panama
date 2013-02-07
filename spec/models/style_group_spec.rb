# encoding : utf-8

require 'spec_helper'

describe "样式使用场景" do
  let(:category) { Category.root }
  let(:shop) { Shop.find_or_create_by :name => 'pepsi' }
  let(:product) { Product.find_or_create_by :name => 'iphone4s', :price => 5999, :category => category, :shop => shop }

  it "访问产品样式 通过 sytles 方法" do
    product.should respond_to(:styles)
  end

  describe "访问 styles" do
    let(:colour) { product.styles.find_or_create_by(:name => :colour) }
    let(:items) { product.styles.find_or_create_by(:name => :items) }
    let(:sizes) { product.styles.find_or_create_by(:name => :sizes) }

    it "访问产品样式 通过 styles" do
      product.styles.where(:name => 'colour')
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