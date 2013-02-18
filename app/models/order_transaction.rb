class OrderTransaction < ActiveRecord::Base

  attr_accessible :buyer_id, :items_count, :seller_id, :state, :total
  has_one :address

  belongs_to :seller, inverse_of: :transactions, class_name: "Shop"
  belongs_to :buyer, inverse_of: :transactions, class_name: "User"

  has_many :items, inverse_of: :transaction, class_name: "ProductItem",  autosave: true

  state_machine :initial => :order do
    
    event :buy do
      transition [:order] => :waiting_paid
    end

    event :back do 
      transition [:waiting_paid] => :order
    end
  end
end
