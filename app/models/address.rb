#encoding: utf-8
class Address < ActiveRecord::Base
  include Custom::Validators

  acts_as_paranoid
  attr_accessible :user_id, :road, :zip_code, :province_id, :city_id, :area_id, :contact_name, :contact_phone

  has_many :transaction, class_name: 'OrderTransaction'
  belongs_to :user
  belongs_to :province, :inverse_of => :address , class_name: "City"  # 省, 州
  belongs_to :city, :inverse_of => :address , class_name: "City"      # 市
  belongs_to :area, :inverse_of => :address , class_name: "City"      # 县

  def address_only
    "#{province.try(:name)}#{city.try(:name)}#{area.try(:name)}#{road}"
  end

  def location
    "#{contact_name}：#{contact_phone}，#{address_only}"
  end

  validates :road, :presence => true
  validates :province_id, :presence => true
  validates :city, :superior => {:target => :province, :att => :city_id }
  validates :area, :superior => {:target => :city , :att => :area_id }
  validates :contact_name, :presence => true
  validates :contact_phone, :presence => true

  private
end
