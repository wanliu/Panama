#encoding: utf-8
#describe: 社区贴子
#
#attributes:
#  content: 内容
#  owner: 所属者(商店与用户)
#  user_id: 发贴人
#  context_html: html内容
#
class Topic < ActiveRecord::Base
  attr_accessible :content, :owner_id, :owner_type, :user_id, :content_html

  belongs_to :owner, :polymorphic => true
  belongs_to :user

  has_many :receives, class_name: "TopicReceive"

  validates :content, :presence => true
  validates :context_html, :presence => true

  validate_presence_of :user
  validate_presence_of :owner
end
