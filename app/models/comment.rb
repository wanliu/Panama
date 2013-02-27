#encoding: utf-8

#describe: 评论模型
class Comment < ActiveRecord::Base
  attr_accessible :content, :user_id


  belongs_to :user
  belongs_to :targeable, :polymorphic => true
  has_many :replies

  validates :content, :presence => true
  validate :validate_user_exists?

  def validate_user_exists?
    errors.add(:user_id, "用户不存！") unless User.exists?(user_id)
  end
end
