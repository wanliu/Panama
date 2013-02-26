module Session
  module Helpers
    def get_session(*args)
      {
        omniauth: {
          'uid' => FactoryGirl.create(:user).uid
        }
      }
    end

    def current_user
      FactoryGirl.create(:user)
    end

    def anonymous
      FactoryGirl.create(:anonymous)
    end
  end
end