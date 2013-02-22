module Session
  module Helpers
    def get_session(*args)
      {
        user: FactoryGirl.create(:user, *args)
      }
    end
  end
end