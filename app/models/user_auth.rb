# 用户认证信息的虚拟模型
class UserAuth
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :company_name, :company_photo, :company_address, :company_summary, 
                :business_license_num, :license_photo,
                :company_legal, :legal_id_number, :id_card_photo, :legal_contact
  
  validates_presence_of :company_name, :company_address, :company_legal, :legal_contact
  validates_length_of :company_summary, :maximum => 100
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
  
  def persisted?
    false
  end
end