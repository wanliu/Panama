#encoding: utf-8
class DirectTransaction < ActiveRecord::Base
  attr_accessible :buyer_id, :seller_id, :operator

  acts_as_status :state, [:uncomplete, :complete, :close]

  scope :uncomplete, where(:state => _get_state_val(:uncomplete))
  scope :completed, where(:state => _get_state_val(:complete))

  belongs_to :buyer, :class_name => "User"
  belongs_to :seller, :class_name => "Shop"
  belongs_to :operator, :class_name => "User"

  has_many :items, :class_name => "ProductItem", :as => :owner, :dependent => :destroy
  has_many :notifications, :as => :targeable, dependent: :destroy
  has_many :transfers, :as => :targeable
  has_one :temporary_channel, as: :targeable, dependent: :destroy

  validates :buyer,  :presence => true
  validates :seller, :presence => true
  validates :number, :presence => true, :uniqueness => true

  before_validation(:on => :create) do
    generate_number
    generate_transfer
  end

  before_create :init_data

  after_create :notice_seller

  after_destroy :notice_destroy, :update_transfer_failer

  after_update :notice_change_state, :update_transfer

  after_commit :create_the_temporary_channel, on: :create

  def init_data
    self.total = items.inject(0){|s, v|  s = s + (v.amount * v.price) }
    self.state = :uncomplete
    self.expired_time = DateTime.now + 3.days
  end

  def as_json(*args)
    attra = super *args
    attra["number"] =  number
    attra["buyer_login"] = buyer.try(:login)
    attra["items_count"] = items_count    
    attra["state_title"] = state_title
    attra["state_name"] = state.name
    attra["created_at"] = created_at.strftime("%Y-%m-%d %H:%M:%S")
    attra
  end

  def state_title
    I18n.t("direct_transaction_state.#{state.name}")
  end

  def update_operator(user)
    results = if operator.nil? && seller.is_employees?(user)
      update_attributes(:operator => user)
    end
    Notification.dual_notify(seller,
      :channel => "/#{seller.im_token}/direct_transactions/dispose",
      :content => "直接交易订单#{number}被#{user.login}处理了",
      :url => seller_open_path,
      :avatar => user.photos.icon,
      :target => self,
      :direct_id => id,
      :exclude => user
    ) do |options|
      options[:channel] = "/direct_transactions/dispose"
    end if results

    buyer.notify(
      "/direct_transactions/dispose",
      "直接交易订单#{number}被#{user.login}处理了",
      :persistent => false,
      :direct_id => id
    )

    results
  end

  def notice_seller
    Notification.dual_notify(seller,
      :channel => "/#{seller.im_token}/direct_transactions/create",
      :content => "你有新的直接交易订单#{number}",
      :url => seller_open_path,
      :avatar => buyer.photos.icon,
      :target => self,
      :direct_id => id
    ) do |options|
      options[:channel] = "/direct_transactions/create"
    end
  end

  def notice_change_state
    if changed.include?("state")
      target = operator.nil? ? seller : operator
      Notification.dual_notify(target,
        :channel => "/#{seller.im_token}/direct_transactions/#{id}/change_state",
        :content => "直接交易订单#{number}状态变更#{state_title}",
        :url => seller_open_path,
        :avatar => buyer.photos.icon,
        :target => self,
        :state => state.name,
        :state_title => state_title,
        :direct_id => id
      ) do |options|
        options[:channel] = "/direct_transactions/change_state"
      end
    end
  end

  def update_transfer
    update_transfer_success
    change_state_update_transfer
  end

  def update_transfer_success
    if changed.include?("state") && state == :complete
      transfers.each{|t| t.update_success }
    end
  end

  def change_state_update_transfer
    if changed.include?("state") && state == :close
      update_transfer_failer
    end
  end

  def update_transfer_failer    
    transfers.each{|t| t.update_failer }    
  end

  def notice_destroy
    target = operator.nil? ? seller : operator
    Notification.dual_notify(target,
      :channel => "/#{seller.im_token}/direct_transactions/destroy",
      :content => "直接交易订单#{number}被删除",
      :avatar => buyer.photos.icon,
      :url => "/shops/#{seller.name}/admins/direct_transactions",
      :direct_id => id,
    ) do |options|
      options[:channel] = "/direct_transactions/destroy"
    end
  end

  def generate_transfer
    items.each do |item|
      transfers.build(
        :amount => -item.amount,        
        :shop_product => item.shop_product)      
    end
  end

  def items_count
    items.inject(0){|s, item| s = s + item.amount }
  end

  
  def generate_number
    _number = (DirectTransaction.max_id + 1).to_s
    _number = "D#{'0' * (9-_number.length)}#{_number}" if _number.length < 9
    self.number = _number
  end

  def self.max_id
    select("max(id) as id")[0].try(:id) || 0
  end

  def self.expired_state
    uncomplete.where("expired_time <= ?", DateTime.now).each do |t|
      t.update_attributes(:state, :close)
    end
  end

  def create_the_temporary_channel
    name = self.class.to_s << "_" << number
    self.create_temporary_channel(targeable_type: 'DirectTransaction', user_id: seller.owner.id, name: name)
  end

  def buyer_open_path
    "/people/#{buyer.login}/direct_transactions#open/#{id}/direct"    
  end

  def seller_open_path
    "/shops/#{seller.name}/admins/direct_transactions#open/#{id}/direct"
  end
end
