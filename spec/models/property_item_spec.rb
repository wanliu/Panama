# encoding: utf-8
require 'spec_helper'

describe PropertyItem do

  let(:apple) { Product.first }
  let(:clothes_types) { apple.property_items[:clothes_type] }
  let(:hat) { clothes_types.select { |it| it.value == "Hat" }.first }

  describe "保存 Item Title" do

    it "查找" do
      hat.value.should eql("Hat")
    end

    it "更改 Hat" do
      hat.title = "帽子"
      hat.save
      hat.title.should eql("帽子")
      cts = Product.first.property_items[:clothes_type]
      hat = cts.select { |it| it.value == "Hat" }.first
      hat.title.should eql("帽子")
    end
  end
end
