#encoding: utf-8
require 'spec_helper'

describe TopicCategory, "帖子分类模型" do
  let(:shop){ FactoryGirl.create(:shop, user: current_user) }

  it{ should belong_to :shop }
  it{ should validate_presence_of :shop }

  it "验证数据" do
    @topic_category = TopicCategory.new(
      shop_id: shop.id,
      name: "服务支持")
    @topic_category.valid?.should be_true

    TopicCategory.create(
      shop_id: shop.id,
      name: "服务支持").valid?.should be_true
  end

end
