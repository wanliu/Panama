# coding:utf-8
class Activity < ActiveRecord::Base
  include Graphical::Display
  include Tire::Model::Search
  include Tire::Model::Callbacks
  include MessageQueue::Activity

  attr_accessor :people_number

  scope :wait,lambda{ where(:status => statuses[:wait]) }
  scope :access,lambda{ where(:status => statuses[:access]) }
  scope :rejected,lambda{ where(:status => statuses[:rejected]) }

  attr_accessible :url, :shop_product_id, :start_time, :end_time, :price, :title, 
                  :description, :like, :participate, :author_id, :status, :rejected_reason

  belongs_to :shop_product
  belongs_to :author, :class_name => "User"
  belongs_to :shop
  has_many :notifications, as: :targeable, class_name: "Notification", dependent: :destroy

  has_many :activity_rules, autosave: true

  has_many :comments, :as => :targeable
  has_many :activities_likes
  has_many :likes, :through => :activities_likes, :source => :user
  has_and_belongs_to_many :attachments, class_name: "Attachment"

  has_many :activities_participates
  has_many :participates, :through => :activities_participates, :source => :user

  # validates_associated :product
  validates_presence_of :author

  validate :validate_update_access?, :on => :update
  
  define_graphical_attr :photos, :handler => :default_photo

  before_create :init_data

  before_destroy do
    validate_destroy_access?
  end

  def notice_author(sender, message)
    notifications.create({
      :user_id => sender.id,
      :mentionable_user_id => author.id,
      :url => "/activities/#{id}",
      :body => message
    })
  end

  def notice_followers
    followers = author.followers.where({:follow_type => User})
    followers.each do |follower|
      notifications.create({
        :user_id => author.id,
        :mentionable_user_id => follower.user_id,
        :url => "/activities/#{id}",
        :body => "有新活动发布"
      })
    end
  end

  def init_data
    self.shop_id = author.shop.id
    self.like = like
    self.participate = participate
  end

  def default_photo
    attachments.first ? attachments.first.file : Attachment.new.file
  end

  validates :title, :activity_price, :start_time, :end_time, :shop_product_id, :presence => true
  validates :activity_price, :numericality => { :greater_than_or_equal_to => 0 }
  validates :price, :numericality => { :greater_than_or_equal_to => 0 }, :allow_nil => true

  def like
    likes.size
  end

  def participate
    participates.size
  end

  def as_json(options = nil)
    atts = super(:include => {
          :author   => {
            :include => :photos },
          :comments => {
            :include => {
              :user => {
                :include => :photos }}}})
    atts["url"] = photos.default
    atts
  end

  def activity_price
    rule = activity_rules.find { |rule| rule.name == 'activity_price' }
    if rule.blank?
      ""
    else
      rule[rule.value_type]
    end
  end

  def self.statuses
    { :wait => 0, :access => 1, :rejected => 2 }
  end

  def start_sale?
    if Activity.statuses[:access] == status
      if start_time < DateTime.now
        return true
      end
    end
    return false
  end

  def send_checked_mail
    UserMailer.delay.send_activity_checked_notify(author.email, author, url)
  end

  def send_rejected_mail
    UserMailer.delay.send_activity_rejected_notify(author.email, author, rejected_reason, url)
  end

  def validate_destroy_access?
    if Activity.statuses[:access] == self.status
      errors.add(:status, "已经审核了,不能删除！")
      return false
    end
  end

  def update_like
    self.update_attribute(:like, like)
  end

  def update_participate
    self.update_attribute(:participate, participate)
  end

  def validate_update_access?
    if Activity.statuses[:access] == Activity.find(self.id).status
      errors.add(:status, "已经审核了,不能修改！")
    end
  end

  def sort_score
    t = ((like * 5) + (participate * 100))
    t = 1 if t <= 0
    t
  end

  def to_indexed_json
    {
      :title   => title,
      :activity_type => activity_type,
      :shop_product_id  => shop_product_id,
      :description    => description,
      :price          => price,
      :start_time_ms  => start_time.to_f,
      :start_time     => start_time,
      :end_time       => end_time,
      :participate    => participate,
      :status      => status,
      :like        => like,
      :score       => sort_score,
      :created_at  => created_at,
      :updated_at  => updated_at,
      :author => {
        :id        =>  author.id,
        :login     =>  author.login,
        :photos    => {
          :icon      => author.photos.icon,
          :header    => author.photos.header,
          :avatar    => author.photos.avatar
        }
      },
      :shop        => {
        :id        => shop.id,
        :name      => shop.name,
        :photos    => {
          :icon      => shop.photos.icon,
          :header    => shop.photos.header,
          :avatar    => shop.photos.avatar
        }
      },
      :photos      => {
        :icon         => photos.icon,
        :header       => photos.header,
        :avatar       => photos.avatar
      },
      :category    => {
        :id        => shop_product.category.id,
        :name        => shop_product.category.name
      }
    }.to_json
  end
end
