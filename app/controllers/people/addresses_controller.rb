class People::AddressesController < People::BaseController

	def index
		@addresses = Address.where(:user_id => current_user.id)
	end

	def create
		@address = Address.new(params[:address])
		@address.user_id = current_user.id
		@address.save
		redirect_to person_addresses_path
	end

	def update
		@address = Address.find(params[:id])
		@address.update_attributes(params[:address])
		redirect_to person_addresses_path
	end

	def destroy
		Address.delete(params[:id])
		redirect_to person_addresses_path
	end
end
