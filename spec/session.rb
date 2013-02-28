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
  end
end