class OrderTransportType

  class << self
    def all
      Settings.order_transport_types || {}
    end

    def exists?(key)
      all[key].present?
    end

    def get(key)
      all[key] || {}
    end
  end
end