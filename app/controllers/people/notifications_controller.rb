class People::NotificationsController < People::BaseController

	def index
		@notifications = Notification.where(:user_id => @people.id)
		respond_to do | format |
			format.html
			format.json
		end
	end
end