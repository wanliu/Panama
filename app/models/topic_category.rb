#encoding: utf-8
#descibe: 帖子类目
class TopicCategory < ActiveRecord::Base
  attr_accessible :name, :shop_id

  belongs_to :shop
  validates :name, presence: true

  validates_presence_of :shop

  private
  def valid_exists?
    if TopicCategory.where("shop_id=? and name=? and id<>?",
    shop_id, name, id.to_s).count > 0
      errors.add(:name, "名称重复了！")
    end
  end
end
