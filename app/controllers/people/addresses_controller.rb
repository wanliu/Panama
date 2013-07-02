class People::AddressesController < People::BaseController

	def index
		@addresses = Address.where(:user_id => current_user.id)
	end

	def edit
		@person = current_user
	end

	def create
		redirect_to person_addresses_path
	end

	def update
		redirect_to person_addresses_path
	end

	def destroy
		redirect_to person_addresses_path
	end
end
