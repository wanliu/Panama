#encoding: utf-8
#describe: 社区贴子
#
#attributes:
#  content: 内容
#  owner: 所属者(商店与用户)
#  user_id: 发贴人
#  context_html: html内容
#  status: 状态
class Topic < ActiveRecord::Base
  include Extract::Mention
  include TextFormatHtml::Configure

  attr_accessible :content, :user, :category, :category_id

  belongs_to :user
  belongs_to :category, class_name: "CircleCategory", foreign_key: :category_id
  belongs_to :circle

  has_many :comments, as: :targeable, dependent: :destroy
  has_many :attachments, class_name: "TopicAttachment", dependent: :destroy

  validates :content, :presence => true

  validates_presence_of :user
  validates_presence_of :category

  validate :valid_category?

  before_save :content_format_html

  def content_format_html
    self.content_html = text_format_html(self.content)
  end

  def as_json(*args)
    attribute = super *args
    attribute["user"] = {
      login: user.login,
      icon_url: user.photos.icon}
    attribute["category"] = {
      name: category.name
    }
    attribute["attachments"] = []
    attachments.each do |atta|
      attribute["attachments"] << atta.attachment.file.url
    end

    attribute
  end

  private
  def valid_category?
    unless circle.categories.exists?(["id=?", category_id])
      errors.add(:category_id, "没有选择分类")
    end
  end
end
