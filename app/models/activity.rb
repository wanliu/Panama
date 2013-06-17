class Activity < ActiveRecord::Base
  include Graphical::Display
  attr_accessible :url, :product_id, :start_time, :end_time, :price,
                  :description, :like, :participate, :author_id

  belongs_to :product
  belongs_to :author, :class_name => "User"

  has_many :activity_rules, autosave: true

  has_many :comments, :as => :targeable
  has_many :activities_likes
  has_many :likes, :through => :activities_likes, :source => :user
  has_and_belongs_to_many :attachments, class_name: "Attachment"

  has_many :activities_participates
  has_many :participates, :through => :activities_participates, :source => :user

  validates_associated :product

  define_graphical_attr :photos, :handler => :default_photo

  def default_photo
    attachments.first ? attachments.first.file : Attachment.new.file
  end

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

  def activity_price
    rule = activity_rules.find { |rule| rule.name == 'activity_price' }
    if rule.blank?
      ""
    else
      rule[rule.value_type]
    end
  end

end
