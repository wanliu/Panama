# encoding: utf-8
require 'spec_helper'

describe Warehouse do
  let(:pepsi)         { Shop.first }
  let(:warehouse)     { Warehouse.create(:shop_id => pepsi) }
  let(:apple)         { Product.first }
  let(:banana)        { Product.create(:name              => 'Banana',
                                       :price             => 200,
                                       :shop              => pepsi,
                                       :category_id       => Category.last.id,
                                       :shops_category_id => apple.shops_category_id) }

  let(:colour)        { Property.find_by_name("colour") }
  let(:sizes)         { Property.find_by_name("sizes") }


  it "创建仓库" do
    Warehouse.create(:shop_id => pepsi).should be_true
  end

  describe "库存统计" do
    before :each do
      # 构成库存
      apple.properties << sizes
      apple.properties << colour
      apple.price_options.create(:property => sizes)
      apple.price_options.create(:property => colour)
      banana.properties << sizes
      banana.properties << colour
      banana.price_options.create(:property => sizes)
      banana.price_options.create(:property => colour)
      @red_l_item   = ProductItem.create(:product => apple, :price => apple.price, :amount => 1, :options => { :sizes => "L", :colour => "red" })
      @green_s_item = ProductItem.create(:product => banana, :price => banana.price, :amount => 1, :options => { :sizes => "S", :colour => "green" })
      warehouse.in(@red_l_item)
      warehouse.in(@green_s_item)
      warehouse.in(ProductItem.create(:product => apple, :price => apple.price, :amount => 1),
                   ProductItem.create(:product => apple, :price => apple.price, :amount => 2),
                   ProductItem.create(:product => apple, :price => apple.price, :amount => 3),
                   ProductItem.create(:product => apple, :price => apple.price, :amount => 4),
                   ProductItem.create(:product => apple, :price => apple.price, :amount => 5),
                   ProductItem.create(:product => apple, :price => apple.price, :amount => 6),
                   ProductItem.create(:product => apple, :price => apple.price, :amount => 7),
        )
    end

    it "库存例表" do
      first = warehouse.inventories.first
      first.should respond_to(:name)
      first.should respond_to(:id)
      first.should respond_to(:total)
      first.should respond_to(:options)
      warehouse.inventories[0].total.should eql(29)
      # first.should respond_to(:created_at)
    end

    it "入库" do
      warehouse.in(ProductItem.create(:product => apple, :price => apple.price, :amount => 1))
      warehouse.inventories[0].total.should eql(30)
      warehouse.in(ProductItem.create(:product => apple, :price => apple.price, :amount => 3),
                    ProductItem.create(:product => apple, :price => apple.price, :amount => 2))
      warehouse.inventories[0].total.should eql(35)
    end

    it "出库" do
      warehouse.out(ProductItem.create(:product => apple, :price => apple.price, :amount => 1))
      warehouse.inventories[0].total.should eql(28)
      warehouse.out(ProductItem.create(:product => apple, :price => apple.price, :amount => 3),
                    ProductItem.create(:product => apple, :price => apple.price, :amount => 2))
      warehouse.inventories[0].total.should eql(23)
    end

    it "库存" do

    end
  end
end
