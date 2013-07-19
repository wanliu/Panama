# 零售商认证信息的虚拟模型
class UserAuth
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming
  
  attr_accessor :user_name, :user_photo, :true_name, :user_id_number, :user_contact
  
  validates_presence_of :user_name, :user_id_number
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
  
  def persisted?
    false
  end
end