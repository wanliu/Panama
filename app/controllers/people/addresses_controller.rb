#encoding: utf-8 
class People::AddressesController < People::BaseController

	def index
		@addresses = Address.where(:user_id => current_user.id)
	end

	def edit
		@address = Address.find(params[:id])
		render layout: false
	end

	def create
		@address = Address.new(params[:address])
		@address.user_id = current_user.id
		unless @address.save
			flash[:error] = "请确定输入的地址非空！"
		end
		redirect_to person_addresses_path
	end

	def update
		@address = Address.find(params[:id])
		unless @address.update_attributes(params[:address]) 
			flash[:error] = "请确定修改后的地址非空！"
		end
		redirect_to person_addresses_path
	end

	def destroy
		Address.delete(params[:id])
		redirect_to person_addresses_path
	end
end
