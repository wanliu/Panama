# encoding: utf-8
require 'spec_helper'

describe Product do
  pending "add some examples to (or delete) #{__FILE__}"

  it "样式的关联 是 style_groups" do
    # product.style_groups.should be_a_kind_of(Mongoid::Relations::Targets::Enumerable)
    should have_many(:style_groups)
  end
end
