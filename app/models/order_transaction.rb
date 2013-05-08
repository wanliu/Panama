#encoding: utf-8

class OrderTransaction < ActiveRecord::Base

  attr_accessible :buyer_id, :items_count, :seller_id, :state, :total, :address
  attr_accessor :total

  has_one :address,
          foreign_key: 'transaction_id'

  belongs_to :seller, class_name: "Shop"
  belongs_to :buyer,
             class_name: "User"

  belongs_to :operator, :class_name => "User", :foreign_key => :operator_id

  has_many  :items,
            class_name: "ProductItem",
            foreign_key: 'transaction_id',
            autosave: true

  validates :state, :presence => true
  validates :items_count, :numericality => true
  validates :total, :numericality => true, :allow_nil => true

  validates_presence_of :buyer
  validates_presence_of :seller_id
  validates_associated :address
  # validates_presence_of :address
  validate :valid_address?

  accepts_nested_attributes_for :address
  # validates_presence_of :address

  after_create :notice_user

  def notice_user
    Notification.create!(
      :user_id => seller.user.id,
      :mentionable_user_id => buyer.id,
      :url => "/shops/#{seller.name}/admins/transactions/#{id}",
      :body => "你有新的订单")
  end

  state_machine :initial => :order do

    event :buy do
      transition [:order] => :waiting_paid
    end

    event :back do
      transition :waiting_paid     => :order,
                 :waiting_delivery => :waiting_paid,
                 :waiting_sign     => :waiting_delivery
    end

    # 等待发货
    event :paid do
      transition [:waiting_paid] => :waiting_delivery
    end

    # 发货
    event :delivered do
      transition :waiting_delivery => :waiting_sign
    end

    # 签收
    event :sign do
      transition [:waiting_sign] => :complete
    end

    after_transition :order            => :waiting_paid,
                     :waiting_paid     => :waiting_delivery do |order, transition|
      token = order.operator.try(:im_token)
      FayeClient.send("/events/#{token}/transaction-#{order.id}-seller",
                      :name => transition.to_name) unless token.blank?
      true
    end

    ## only for development
    if Rails.env.development?
      after_transition :waiting_paid      => :order,
                       :waiting_delivery  => :waiting_paid,
                       :waiting_sign      => :waiting_delivery do |order, transition|
        token = order.operator.try(:im_token)
        FayeClient.send("/events/#{token}/transaction-#{order.id}-seller",
                        :name => transition.to_name,
                        :event => :back) unless token.blank?
      end
    end

    after_transition :waiting_delivery => :waiting_sign do |order, transition|
      token = order.buyer.try(:im_token)
      FayeClient.send("/events/#{token}/transaction-#{order.id}-buyer",
                      :name => transition.to_name,
                      :event => :delivered) unless token.blank?
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

  private
  def valid_address?
    puts "state: #{state_name}"
    unless state_name == :order
      errors.add(:address, "地址不存在！") if address.nil?
    end
  end
end
