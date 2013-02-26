class OrderTransaction < ActiveRecord::Base

  attr_accessible :buyer_id, :items_count, :seller_id, :state, :total
  has_one :address,
          foreign_key: 'transaction_id'

  belongs_to :seller, class_name: "Shop"
  belongs_to :buyer,
             class_name: "User"

  has_many :items,
           class_name: "ProductItem",
           foreign_key: 'transaction_id',
           autosave: true

  validates :state, :presence => true
  validates :items_count, :numericality => true
  validates :total, :numericality => true

  validates_presence_of :buyer
  validates_presence_of :seller_id
  # validates_presence_of :address

  state_machine :initial => :order do

    event :buy do
      transition [:order] => :waiting_paid
    end

    event :back do
      transition [:waiting_paid] => :order
    end
  end
end