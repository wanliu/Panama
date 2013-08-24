class UserChecking < ActiveRecord::Base
  attr_accessible :user_id, :service_id, :industry_type,
                  :shop_name, :shop_photo, :shop_url, :shop_summary,
                  :company_name, :company_address, :company_license, :company_license_photo,
                  :ower_name, :ower_photo, :ower_shenfenzheng_number, :phone, :products_added,
                  :rejected, :rejected_reason, :checked
  attr_accessor :uploader_secure_token

  belongs_to :user
  belongs_to :service

  validates :user_id, presence: true, uniqueness: true
  validates :service_id, presence: true
  validates :industry_type, presence: true, if: :service_choosen?

  mount_uploader :company_license_photo, ImageUploader
  mount_uploader :ower_photo, ImageUploader
  mount_uploader :shop_photo, ImageUploader


  def current_step
    if service.service_type == "buyer"
      find_buyer_current_step
    else
      find_seller_current_step
    end
  end

  def update_rejected_times
    self.rejected_times = rejected_times + 1
    save
  end

  def send_checked_mail
    UserMailer.delay.send_user_checked_notify(user.email, ower_name, shop_url)
  end

  def send_rejected_mail
    UserMailer.delay.send_user_rejected_notify(user.email, ower_name, rejected_reason, shop_url)
  end

  protected
    def service_choosen?
      persisted? && !service.blank?
    end

    def industry_choosen?
      persisted? && !industry_type.blank?
    end

    def company_information_finished?
      persisted? && !company_name.blank?
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
end
