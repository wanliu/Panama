require 'orm_fs'

class Content < ActiveRecord::Base
  attr_accessible :lock, :name, :template, :contentable_type, :contentable_id, :contentable
  belongs_to :shop

  has_many :resources
  belongs_to :contentable, :polymorphic => true

  validates :name, presence: true
  validates :template, presence: true

  scope :lookup_name, ->(name){ where(:name => name) }


  def resource
    resources.first
  end

end
