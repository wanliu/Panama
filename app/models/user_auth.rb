#encoding: utf-8

# 零售商认证信息的虚拟模型
class UserAuth
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  ATTR_FIELDS = [:ower_photo, :ower_name, :ower_shenfenzheng_number, :phone]
  attr_accessor *ATTR_FIELDS

  # 在这里添加不能重复的字段
  # 这是个私有方法，放在前端以方便添加
  def uniqueness_fields
    [:ower_shenfenzheng_number]
  end
  private :uniqueness_fields

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end unless attributes.blank?
  end

  def update_options
    options = {}
    ATTR_FIELDS.each do |field|
      value = send(field)
      options[field] = value unless value.blank?
    end
    options
  end

  def persisted?
    false
  end

  protected
    def uniqueness_fields_validate
      uniqueness_fields.each do |field|
        unless UserChecking.where(field => send(field)).blank?
          errors.add(field, "已经被注册！请另外选择")
        end
      end
    end
end