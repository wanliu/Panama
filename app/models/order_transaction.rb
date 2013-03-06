#encoding: utf-8

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

  after_create :notice_user

  def notice_user
    Notification.create!(
      :user_id => seller.user.id,
      :mentionable_user_id => buyer.id,
      :url => "/shops/#{seller.name}/admins/pending/#{id}",
      :body => "你有新订单")
  end

  state_machine :initial => :order do

    event :buy do
      transition [:order] => :waiting_paid
    end

    event :back do
      transition [:waiting_paid] => :order
    end
  end

  def build_items(item_ar)
    item_ar.each { |item| items.build(item) }
    self
  end

  def update_total_count
    self.items_count = items.inject(0) { |s, item| s + item.amount }
    self.total = items.inject(0) { |s, item| s + item.total }
  end
end
