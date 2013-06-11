class Activity < ActiveRecord::Base

  attr_accessible :url, :product_id, :start_time, :end_time, :price, :activity_price,
                  :description, :like, :participate, :author_id

  belongs_to :product
  belongs_to :author, :class_name => "User"

  has_many :activity_rules

  has_many :comments, :as => :targeable
  has_many :activities_likes
  has_many :likes, :through => :activities_likes, :source => :user

  has_many :activities_participates
  has_many :participates, :through => :activities_participates, :source => :user

  validates_associated :product

  validates :price, :presence => true


  def like
    likes.size
  end

  def participate
    participates.size
  end


  def as_json(options = nil)
    super(:include => {
          :author   => {
            :include => :photos },
          :comments => {
            :include => {
              :user => {
                :include => :photos }}}})
  end
end
