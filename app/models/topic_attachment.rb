#describe: 帖子附件
class TopicAttachment < ActiveRecord::Base
  attr_accessible :attachment_id, :topic_id

  belongs_to :attachment
  belongs_to :topic

  validates :attachment_id, :presence => true
  validates :topic_id, :presence => true

  validates_presence_of :attachment
  validates_presence_of :topic

  def self.creates(attachments, topic_id = nil)
    opt = topic_id.nil? ? {} : {topic_id: topic_id}
    attachments.each do |atta|
      opt['attachment_id'] = atta.is_a?(Attachment) ? atta.id : atta
      create(opt)
    end
  end

end
