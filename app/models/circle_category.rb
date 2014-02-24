#encoding: utf-8

class CircleCategory < ActiveRecord::Base
  attr_accessible :circle_id, :name
  acts_as_paranoid

  validates :name, :presence => true
  validate :valid_unqi_name?

  has_many :topics, :foreign_key => :category_id

  def valid_unqi_name?
    if CircleCategory.exists?(["circle_id=? and name=? and id<>?",
      circle_id, name, id.to_s])
      errors.add(:name, "已经存在了！")
    end
  end
end
