#encoding: utf-8

# 供应商认证信息的虚拟模型
class ShopAuth
  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  ATTR_FIELDS = [:user_id, :company_name, :address_id, :company_license,
                 :shop_name, :shop_summary, :company_license_photo,
                 :ower_name, :ower_photo, :ower_shenfenzheng_number, :phone]

  attr_accessor *ATTR_FIELDS

  # 在这里添加不能重复的字段
  UNIQUENESS_FIELDS = [:company_license, :ower_shenfenzheng_number, :shop_name]

  # 在这里添加不是必须出现的字段
  UN_PRESENCE_FIELDS = [:company_license_photo, :ower_photo, :shop_summary]

  # validates_presence_of :shop_name
  # validates_length_of :shop_summary, :maximum => 200
  validates *(ATTR_FIELDS - UN_PRESENCE_FIELDS), presence: true
  validates :ower_shenfenzheng_number, format: { with: /^\d{17}[0-9xX]$/, message: "请填写真实有效的第二代身份证号码" }
  validates :phone, format: { with: /^\d(\d|-?){5,11}\d$/, message: "请确定号码真实有效，只能包含数字或‘-’" }
  validates :company_license, format: { with: /^\w{10,}$/, message: "请输入真实有效的营业执照号，只能包含字母或数字" }
  # validates :shop_url, :shop_name, format: { with: /^[a-zA-Z0-9_\u4e00-\u9fa5]+$/, message: "只能包含数字、字母、汉字和下划线（_­）组成，不能有空格" }
  validates :shop_name, format: { with: /^[a-zA-Z0-9_\u4e00-\u9fa5]+$/, message: "只能包含数字、字母、汉字和下划线（_­）组成，不能有空格" }
  validates :ower_name, presence: true, format: { with: /^[\u4e00-\u9fa5]{2,}$/, message: "请确定姓名真实有效，不能有空格" }
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

  def get_validate_params(shop_id, user_checking_id)
    @shop_id = shop_id
    @user_checking_id = user_checking_id   
  end

  def update_options
    options = {}
    ATTR_FIELDS.each do |field|
      value = send(field)
      options[field] = value unless value.blank? || field.to_s.start_with?('shop_')
    end
    options
  end

  protected
    def uniqueness_fields_validate
      UNIQUENESS_FIELDS.each do |field|
        value = send(field)
        error = "#{value}已经被注册！请另外选择"
        if field == :shop_name
          unless Shop.where("name = ? and id<>?", value, @shop_id.to_s).blank?
            errors.add(field, error)
          end
        else
          unless UserChecking.where("#{ field } = ? and user_id <> ?", value, user_id).blank?
            errors.add(field, error)
          end
        end
      end
    end
end