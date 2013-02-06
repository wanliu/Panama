# encoding : utf-8

require 'spec_helper'

describe "样式使用场景" do
  let(:product) { Product.new }

  it "样式的关联 是 style_groups" do 
    product.style_groups.should be_a_kind_of(Mongoid::Relations::Targets::Enumerable)

  end

  it "访问产品样式 通过 sytles 方法" do
    product.sytles.should exist
  end

  describe "访问 styles" do 
    let(:colour) { product.style_groups.build(:name => :colour) }
    let(:items) { product.style_groups.build(:name => :items) }
    let(:sizes) { product.style_groups.build(:name => :sizes) }

    it "访问产品样式 通过 styles" do
      product.styles[:colour].should eql(colour)
    end

    it "增加一个颜色值" do
      red = colour.add_color_item('red', 0xFF0000)
      blue = colour.add_color_item('blue', [0,255,0])

      colour.items.should include(red, blue)
    end

    it "增加一个 item" do
      up = items.add_item('上衣', 'up')

      items.items.should include(up)
    end

    let(:s) {sizes.add_value_item('S')}

    it "增加一个 size" do 
      sizes.items.should include(s)
    end

    it "检索 一个尺寸" do 
      sizes.has?('S').should be_true
    end

  end

end