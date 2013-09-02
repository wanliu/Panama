#coding: utf-8 

class People::AddressesController < People::BaseController

	def index
		@addresses = Address.where(:user_id => @people.id)
	end

	def edit
		@address = Address.find(params[:id])
		render layout: false
	end

	def create
		@address = Address.create(params[:address].merge(
			user_id: @people.id
		))
		unless @address.valid?
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