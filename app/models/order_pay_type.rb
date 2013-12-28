class OrderPayType
  class << self
    def all
      Settings.order_pay_types || {}
    end

    def exists?(key)
      all[key].present?
    end

    def get(key)
      all[key] || {}
    end
  end
end