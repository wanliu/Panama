#encoding: utf-8
require 'spec_helper'

describe TopicAttachment, "帖子附件模型" do
  let(:shop){ FactoryGirl.create(:shop, user: current_user) }
  let(:attachment){ FactoryGirl.create(:attachment) }

  it{ should belong_to :attachment  }
  it{ should belong_to :topic  }

  it{ should validate_presence_of :topic }
  it{ should validate_presence_of :attachment }

  before :each do
    @topic = shop.topics.create(
      :status => :circle,
      :user_id => anonymous.id,
      :content => "就这样吧!")
  end

  it "验证数据" do
    topic_attachment = TopicAttachment.new(
      topic_id: @topic.id,
      attachment_id: attachment.id)
    topic_attachment.valid?.should be_true
    topic_attachment.topic_id = 0
    topic_attachment.valid?.should be_false

    topic_attachment.topic_id = @topic.id
    topic_attachment.valid?.should be_true

    topic_attachment.attachment_id = 0
    topic_attachment.valid?.should be_false

    topic_attachment.attachment_id = attachment.id
    topic_attachment.valid?.should be_true
  end

  describe "类方法" do
    before do
      @attachment1 = FactoryGirl.create(:attachment)
      @attachment2 = FactoryGirl.create(:attachment)
    end

    it "帖子关连添加多个附件" do
      @topic.attachments.creates([@attachment1, @attachment2])
      @topic.attachments.map{|a| a.attachment}.should eq([@attachment1, @attachment2])
    end

    it "添加多个附件" do
      expect{
        TopicAttachment.creates([@attachment1, @attachment2], @topic.id)
      }.to change(TopicAttachment, :count).by(2)
    end

  end

end
