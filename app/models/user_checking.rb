#encoding: utf-8
class UserChecking < ActiveRecord::Base
  include Graphical::Display

  attr_accessible :user_id, :industry_type, :service,
                  :company_name, :address, :company_license, :company_license_photo,
                  :ower_name, :ower_photo, :ower_shenfenzheng_number, :phone, :products_added,
                  :rejected, :rejected_reason, :checked, :address_id
  attr_accessor :uploader_secure_token

  belongs_to :user
  belongs_to :address

  validates :ower_shenfenzheng_number, presence: true, if: :industry_choosen?
  validates :user_id, presence: true, uniqueness: true
  validates :industry_type, presence: true, if: :service_choosen?

  validate :validate_user_already_exists?

  mount_uploader :company_license_photo, ImageUploader
  mount_uploader :ower_photo, ImageUploader
  # mount_uploader :shop_photo, ImageUploader

  define_graphical_attr :ower_photos, :handler => :ower_photo
  # define_graphical_attr :shop_photos, :handler => :shop_photo
  after_update do 
    clone_delivery_address    
    update_relation_index
  end

  def checked_notify
    user.notify('/audit/user', "恭喜你，你的资料审核通过……", :avatar => user.icon, :target => self, :url => default_url)
  end

   def unchecked_notify
    user.notify('/audit/user', "很遗憾，你的资料审核未通过，请重新提起审核……", :avatar => user.icon, :target => self, :url => default_url)
  end

  def unchecked
    update_attributes(checked: false)
    unreject
  end

  def unreject
    update_attributes(rejected: false)
  end

  def current_step
    if service == "buyer"
      find_buyer_current_step
    else
      find_seller_current_step
    end
  end

  def as_json(*args)
    attas = super *args
    attas['ower_photos'] = ower_photos.attributes
    attas['user'] = {
      :id => user.id,
      :login => user.login,
      :photos => user.photos.attributes,
      :services => "#{ user.services.join(',')}"   #将服务类型的数组转换成字符串
    }
    attas['shop'] = {
      :id => shop.try(:id),
      :name => shop.try(:name),
      :photos => shop.try(:photos).try(:attributes)
    }
    # attas['shop_photos'] = shop_photos.attributes
    attas
  end

  def grapical_handler

  end

  def site_url
    Settings.site_url "http://panama.wanliu.biz"
  end

  def shop
    user.try(:shop)
  end

  def login_name
    user.login
  end
  
  def update_rejected_times
    self.rejected_times = rejected_times + 1
    save
  end

  def default_url
    url = if user.shop.blank?
      File.join(Settings.site_url, "/people/#{user.login}")
    else
      File.join(Settings.site_url, user.shop.shop_url.to_s)
    end
  end

  def send_checked_mail
    UserMailer.delay.send_user_checked_notify(user.email, ower_name, default_url)
    checked_notify
  end

  def send_rejected_mail
    UserMailer.delay.send_user_rejected_notify(user.email, ower_name, rejected_reason, default_url)
    unchecked_notify
  end

  def self.users_checking_query
    joins("left join users us on user_checkings.user_id = us.id
           right join shops sh on sh.user_id = us.id
           left join addresses ad on ad.id = user_checkings.address_id")
  end

  def update_relation_index

  end

  def update_user_index
    User.index_update_by_query(
      :query => {
        :term => {
          "id" => user_id
        }
      },
      :update => {
        :industry_type => industry_type,
        :service => service,
        :phone => phone
      }
    )
  end

  def update_shop_index
    Shop.index_update_by_query(
      :query => {
        :term => {
          "user.id" => user_id
        }
      },
      :update => {
        :industry_type => industry_type,
        :phone => phone
      }
    )
  end

  protected
    def service_choosen?
      persisted? && service.present?
    end

    def industry_choosen?
      persisted? && industry_type.present? && changed_attributes["industry_type"].present?
    end

    def company_information_finished?
      persisted? && company_name.present?
    end

    def products_added?
      persisted? && products_added
    end

    def find_buyer_current_step
      if company_information_finished?
        "waiting_audited"
      elsif industry_choosen?
        "authenticate_license"
      elsif service_choosen?
        "pick_industry"
      end
    end

    def find_seller_current_step
      if products_added?
        "waiting_audit"
      elsif company_information_finished?
        "pick_product"
      elsif industry_choosen?
        "authenticate_license"
      elsif service_choosen?
        "pick_industry"
      end
    end

  private
  def validate_user_already_exists?
    if UserChecking.where("user_id=? and id<>?", user_id, id.to_s).count > 0
      errors.add(:user_id, "该用户已经存在了，服务商！")
    end
  end

  def clone_delivery_address
    if changed.include?("address_id")
      if address.present?
        user.delivery_addresses.create(address.attributes)
      end
    end
  end
end
