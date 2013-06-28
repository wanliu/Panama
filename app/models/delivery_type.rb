class DeliveryType < ActiveRecord::Base
  attr_accessible :name, :description

  has_many :transaction,
           class_name: 'OrderTransaction'

  validates :name, :presence => true, :uniqueness => true
end
