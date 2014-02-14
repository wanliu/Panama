# encoding: utf-8
require 'spec_helper'

describe PropertyValue do

  let (:pepsi) { Shop.where(name: 'Pepsi').first }
  let (:apple) { Product.first }


  describe "类型储值" do

    it "apple 会有 material 键" do
      apple.should respond_to(:material)
    end

    it "apple 会有 weight 键" do
      apple.should respond_to(:weight)
    end

    it "apple 会有 clothes_type 键" do
      apple.should respond_to(:clothes_type)
    end
  end

  describe "写属性" do

    it "material" do
      apple.material = "leather"
      apple.material.should == "leather"
      apple.material.should be_a(String)
    end

    it "weight" do
      apple.weight = 28
      apple.weight.should == 28
      apple.weight.should be_a(Fixnum)
    end

    it "clothes_type" do
      apple.clothes_type.should == "Pants"
      apple.clothes_type = "Hat"
      apple.clothes_type.should == "Hat"
    end

    it "写 clothes_type 并保存" do
      apple.clothes_type.should == "Pants"
      apple.clothes_type = "Hat"
      apple.save

      Product.first.clothes_type.should == "Hat"
    end

    it "写无效的<set> clothes_type" do
      apple.clothes_type.should == "Pants"
      apple.clothes_type = "Test"
      apple.clothes_type.should == "Pants"
    end

    it "写无效的<set> clothes_type 不会保存" do
      apple.clothes_type.should == "Pants"
      apple.clothes_type = "Test"

      apple.save

      Product.first.clothes_type.should == "Pants"
    end

    it "写 BigDecimal 类型" do
      apple.longitude = BigDecimal.new("26.4226")
      apple.latitude = BigDecimal.new("112.831113")
      apple.longitude.should eql(26.4226)
      apple.longitude.should be_a(BigDecimal)
      apple.latitude.should eql(112.831113)
      apple.latitude.should be_a(BigDecimal)
    end

    it "写 BigDecimal 类型, 并保存" do
      apple.longitude = BigDecimal.new("26.4226")
      apple.latitude = BigDecimal.new("112.831113")
      apple.longitude.should eql(26.4226)
      apple.longitude.should be_a(BigDecimal)
      apple.latitude.should eql(112.831113)
      apple.latitude.should be_a(BigDecimal)

      apple.save

      Product.first.longitude.should eql(26.4226)
      Product.first.latitude.should eql(112.831113)
    end

    it "写 DateTime 类型" do
      apple.production_date = DateTime.new(2010,10,20, 18,48,56)
      apple.production_date.should eql(DateTime.new(2010,10,20, 18,48,56))
      apple.production_date.should be_a(ActiveSupport::TimeWithZone)
    end
  end
end
