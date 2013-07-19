class UserChecking < ActiveRecord::Base
  attr_accessible :user_id, :service_id, :industry_type,
                  :shop_name, :shop_photo, :shop_url, :shop_summary,
                  :company_name, :company_address, :company_license, :company_license_photo,
                  :ower_name, :ower_photo, :ower_shenfenzheng_number, :phone
  attr_accessor :company_information_finished, :audited

  belongs_to :user
  belongs_to :service

  validates :user_id, presence: true, uniqueness: true
  validates :service_id, presence: true
  validates :industry_type, presence: true, if: :service_choosen?

  def current_step
    if service.service_type == "buyer"
      find_buyer_current_step
    else
      find_seller_current_step
    end
  end

  protected
    def service_choosen?
      persisted? && !service.nil?
    end

    def industry_choosen?
      persisted? && !industry_type.nil?
    end

    def company_information_finished?
      persisted? && company_information_finished
    end

    def audited?
      audited
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
      if audited?
        "pick_product"
      else
        find_buyer_current_step
      end
    end
end
