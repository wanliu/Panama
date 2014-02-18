# coding:utf-8
class Unit < ActiveRecord::Base
  attr_accessible :code, :name, :child_id, :percentage

  belongs_to :child, class_name: "Unit", foreign_key: 'child_id'

  validates :name, presence: true, uniqueness: true
  validates :percentage, presence: true, numericality: { greater_than: 0 }

end