class People::AddressesController < People::BaseController

	def index
		@addresses = Address.where(:user_id => current_user.id)
	end
end
