#encoding: utf-8

# 零售商认证信息的虚拟模型
class UserAuth
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  ATTR_FIELDS = [:user_id, :ower_photo, :ower_name, :ower_shenfenzheng_number, :phone, :chekced, :company_name, :address_id]
  attr_accessor *ATTR_FIELDS

  # 在这里添加不能重复的字段
  UNIQUENESS_FIELDS = [:ower_shenfenzheng_number]

  validates :ower_shenfenzheng_number, format: { with: /^\d{17}[0-9xX]$/, message: "请填写真实有效的第二代身份证号码" }
  validates :phone, format: { with: /^\d(\d|-?){5,11}\d$/, message: "请确定号码真实有效，只能包含数字或‘-’" }
  validates :ower_name, presence: true, format: { with: /^[\u4e00-\u9fa5]{2,}$/, message: "请确定姓名真实有效，不能有空格" }
  validates :ower_shenfenzheng_number, presence: true
  validates :phone, presence: true

  def initialize(attributes = {})
    attributes = attributes.symbolize_keys
    attributes.each do |name, value|
      send("#{name}=", value) unless value.blank? || !ATTR_FIELDS.include?(name)
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
      UNIQUENESS_FIELDS.each do |field|
        unless UserChecking.where("#{ field } = ? and user_id <> ?", send(field), user_id).blank?
          errors.add(field, "已经被注册！请另外选择")
        end
      end
    end
end