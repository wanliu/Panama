#encoding: utf-8
class DeliveryAddress < ActiveRecord::Base
  include Custom::Validators

  acts_as_paranoid
  attr_accessible :user_id, :road, :zip_code, :province_id, :city_id, :area_id, :contact_name, :contact_phone

  belongs_to :user
  belongs_to :province, :inverse_of => :address , class_name: "City"  # 省, 州
  belongs_to :city, :inverse_of => :address , class_name: "City"      # 市
  belongs_to :area, :inverse_of => :address , class_name: "City"      # 县

  validates :contact_phone, :format => { :with => /^\d{11}$|\d{3,4}-\d{6,8}(?:-\d{1,4})?$/ }
  validates :zip_code, :format => { :with => /[1-9]\d{5}(?!\d)/, :message => "邮政编码必须为六位数字"}

  def location_area
    "#{province.try(:name)}#{city.try(:name)}#{area.try(:name)}"
  end

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

  validate :valid_address_uniqueness?

  private
  def valid_address_uniqueness?
    if DeliveryAddress.exists?(["
      id<>? and
      road=? and
      user_id=? and
      province_id=? and
      city_id=? and
      area_id=? and
      contact_name=? and
      contact_phone=?", id.to_s, road, user_id, province_id,
      city_id, area_id, contact_name, contact_phone])
      errors.add(:province_id, "地址已经存在了！")
    end
  end
end
