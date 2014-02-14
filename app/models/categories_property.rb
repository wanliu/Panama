#encoding: utf-8

class CategoriesProperty < ActiveRecord::Base
  scope :filters,-> { where(:filter_state => true) }

  has_many :values, class_name: :CategoryPropertyValue,
  :dependent => :destroy, :foreign_key => :category_property_id

  belongs_to :category
  belongs_to :property

  validate :uniq_property?

  def join_filter_state
    update_attribute(:filter_state, true)
  end

  def find_by_value(value)
    values.find_by(value: value)
  end

  private
  def uniq_property?
    if CategoriesProperty.exists?([
      "category_id=? and property_id=? and id<>?",
      category_id,
      property_id,
      id.to_s
    ])
      errors.add(:property_id, "属性已经存在了！")
    end
  end
end