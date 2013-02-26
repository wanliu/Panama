# encoding : utf-8
require 'spec_helper'

describe StyleItem do
  describe "关联(Association)" do
    it { should belong_to(:style_group) }
    it { should have_many(:style_pairs) }
    it { should have_many(:sub_products).through(:style_pairs) }
  end

  describe "验证(Validates)" do
    it { should validate_presence_of(:title) }
    it { should validate_uniqueness_of(:title).scoped_to(:style_group_id)
                                              .with_message(/this tltle: arbitrary_string exsits under the same stylegroup/) }
    it { should validate_presence_of(:value) }
    it { should validate_uniqueness_of(:value).scoped_to(:style_group_id)
                                              .with_message(/this value: arbitrary_string exsits under the same stylegroup/) }
    it { should validate_presence_of(:style_group_id) }
  end
end