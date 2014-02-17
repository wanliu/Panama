#encoding: utf-8
class Address < ActiveRecord::Base
  include Custom::Validators

  acts_as_paranoid
  attr_accessible :road, :zip_code, :province_id, :city_id, :area_id, :contact_name, :contact_phone

  belongs_to :province, :inverse_of => :address , class_name: "City"  # 省, 州
  belongs_to :city, :inverse_of => :address , class_name: "City"      # 市
  belongs_to :area, :inverse_of => :address , class_name: "City"      # 县

  validates :contact_phone, :format => { :with => /^\d{11}$|\d{3,4}-\d{6,8}(?:-\d{1,4})?$/ }

  after_update do 
    update_relation_index
  end
 
  def address_only
    "#{province.try(:name)}#{city.try(:name)}#{area.try(:name)}#{road}"
  end

  def location
    "#{contact_name}：#{contact_phone}，#{address_only}"
  end

  def update_relation_index
    update_user_index
    update_shop_index
  end

  def update_user_index
    User.index_update_by_query(
      :query => {
        :term => {
          "address_id" => id
        }
      },
      :update => {
        :address => address_only
      }
    )
  end

  def update_shop_index
    Shop.index_update_by_query(
      :query => {
        :term => {
          "address_id" => id
        }
      },
      :update => {
        :address => address_only
      }
    )
  end

  validates :road, :presence => true
  validates :province_id, :presence => true
  validates :city, :superior => {:target => :province, :att => :city_id }
  validates :area, :superior => {:target => :city , :att => :area_id }
  validates :contact_name, :presence => true
  validates :contact_phone, :presence => true

  private
end
