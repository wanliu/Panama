#encoding: utf-8

# 供应商认证信息的虚拟模型
class ShopAuth
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  ATTR_FIELDS = [:user_id, :shop_name, :shop_photo, :shop_url, :shop_summary,
                 :company_name, :company_address, :company_license, :company_license_photo,
                 :ower_name, :ower_photo, :ower_shenfenzheng_number, :phone]
  attr_accessor *ATTR_FIELDS

  # 在这里添加不能重复的字段
  UNIQUENESS_FIELDS = [:shop_name, :shop_url, :company_license, :ower_shenfenzheng_number]

  # 在这里添加不是必须出现的字段
  UN_PRESENCE_FIELDS = [:shop_photo, :company_license_photo, :ower_photo]

  # validates_presence_of :shop_name
  validates_length_of :shop_summary, :maximum => 200
  validates *(ATTR_FIELDS - UN_PRESENCE_FIELDS), presence: true
  validates :ower_shenfenzheng_number, format: { with: /^\d{17}[0-9xX]$/, message: "请填写真实有效的第二代身份证号码" }
  validates :phone, format: { with: /^\d{3,5}-?\d{6,}$/, message: "电话号码只能由数字和‘-’组成" }
  validates :company_license, format: { with: /^\d{10,}$/, message: "请输入真实有效的营业执照号，只能包含数字" }
  validates :shop_url, format: { with: /^\w{6,}$/, message: "地址只能以数字、字母和下划线（_­）组成，不能有空格" }
  validate :uniqueness_fields_validate

  def initialize(attributes = {})
    attributes = attributes.symbolize_keys
    attributes.each do |name, value|
      send("#{name}=", value) unless value.blank? || !ATTR_FIELDS.include?(name)
    end unless attributes.blank?
  end

  def persisted?
    false
  end

  def update_options
    options = {}
    ATTR_FIELDS.each do |field|
      value = send(field)
      options[field] = value unless value.blank?
    end
    options
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