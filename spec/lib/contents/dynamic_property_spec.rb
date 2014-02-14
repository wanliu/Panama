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
      price_option = @apple.price_options.first
      price_option.optionable.should eq @apple
      price_option.property.should eq @apple.category.price_options.first.property
    end

    it "同步 price_options 并保存" do
      @apple.save.should be_true

      price_options = Product.first.price_options
      price_option = Product.first.price_options.first
      price_option.optionable.should eql Product.first
      price_option.property.should eql Product.first.category.price_options.first.property
    end

    it "同步 category prices_definition" do
      @apple.prices_definition.should eq(@apple.category.prices_definition)
    end

    it "同步 prices_definition 并保存" do
      @apple.save.should be_true
      Product.first.prices_definition.should eq(@apple.category.prices_definition)
    end

    it "update_attribute" do
      @apple.update_attributes(:make_in => "China")
      Product.first.make_in.should == "China"
    end

    it "update_attribute 2's" do
      @apple.update_attributes(:make_in => "China")
      Product.first.make_in.should == "China"
      @apple.update_attributes(:make_in => "British")
      Product.first.make_in.should == "British"
    end
  end
end