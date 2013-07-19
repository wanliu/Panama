# 供应商认证信息的虚拟模型
class ShopAuth
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :shop_name, :shop_photo, :shop_url, :shop_summary,
                :store_name, :store_address, :business_license_num, :license_photo,
                :legal_name, :legal_photo, :legal_id_number, :legal_phone

  validates_presence_of :shop_name
  validates_length_of :shop_summary, :maximum => 200

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end unless attributes.blank?
  end

  def persisted?
    false
  end

  def update_options
    # attributes
    # { name: shop_name }
  end
end