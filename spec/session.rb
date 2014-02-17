#encoding: utf-8
module Session
  module Helpers
    def get_session(*args)
      {
        user_id: current_user.uid
      }
    end

    def current_user
      @current_user ||= FactoryGirl.create(:user)
    end

    def anonymous
      FactoryGirl.create(:anonymous)
    end

    def current_user_address
      province = FactoryGirl.create(:province)
      city = province.children.create(name: "衡阳", ancestry: province)
      area = city.children.create(name: "耒阳", ancestry: city)
      FactoryGirl.create(:address,
                         user: current_user,
                         province: province,
                         city: city,
                         area: area,
                         targeable: nil)
    end

    def my_cart
      current_user.cart
    end
  end
end