#encoding: utf-8

#describe: 评论模型
class Comment < ActiveRecord::Base
  attr_accessible :content, :targeable_id, :targeable_type, :user_id

  belongs_to :product
  belongs_to :user

  belongs_to :targeable, :polymorphic => true

  validates :content, :presence => true
end
