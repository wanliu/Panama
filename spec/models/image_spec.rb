# encoding: utf-8
require 'spec_helper'

describe Image do
  let(:img) { FactoryGirl.create(:image) }

  it { belong_to :imageable }

  it "获取 100x100 的 url" do
    img.url("100x100").should == "file_name.gif!100x100"
  end

  it "获取 200x200 的 url" do
    img.url("200x200").should == "file_name.gif!200x200"
  end

  it "默认的图片" do
    default_image = FactoryGirl.create(:image, filename: nil)
    default_image.url.should == "http://panama-img.b0.upaiyun.com/product_blank.gif"
  end
end
