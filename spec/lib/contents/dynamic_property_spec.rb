# encoding: utf-8
require 'spec_helper'
require 'panama_core/dynamic_property'

describe PanamaCore::DynamicProperty do

  describe "attach_properties!" do
    before :each do
      @apple = Product.first
      @apple.attach_properties!

    end

    it "同步 category properties" do
      @apple.properties.should eq(@apple.category.properties)
    end

    it "同步 category 并保存 " do
      @apple.save.should be_true

      Product.first.properties.should eq(@apple.category.properties)

    end

    it "同步 category property_items" do
      items = @apple.category.properties.inject([]) { |a, prop| a.concat prop.items }
      @apple.property_items.should eq(items)
    end

    it "同步 property_items 并保存" do
      @apple.save.should be_true
      items = @apple.category.properties.inject([]) { |a, prop| a.concat prop.items }

      Product.first.property_items.should eq(items)
    end

    it "同步 category price_options" do
      @apple.price_options.should eq(@apple.category.price_options)
    end

    it "同步 price_options 并保存" do
      @apple.save.should be_true

      Product.first.price_options.should eq(@apple.category.price_options)
    end

    it "同步 category prices_definition" do
      @apple.prices_definition.should eq(@apple.category.prices_definition)
    end

    it "同步 prices_definition 并保存" do
      @apple.save.should be_true
      Product.first.prices_definition.should eq(@apple.category.prices_definition)
    end
  end
end