# coding: utf-8
class People::DeliveryAddressesController < People::BaseController

	def index
		@addresses = DeliveryAddress.all
	end

	def new
		@address = DeliveryAddress.new
	end

	def edit
		@address = DeliveryAddress.find(params[:id])
		render layout: false
	end

	def create
		@address = @people.delivery_addresses.create(params[:delivery_addresses])
		if @address.valid?
			flash[:success] = "创建收货地址成功！"
		else
			flash[:error] = "请确定输入的地址非空！"
		end
		redirect_to person_delivery_addresses_path
	end

	def update
		@address = DeliveryAddress.find(params[:id])
		if @address.update_attributes(params[:delivery_address])
			flash[:success] = "修改收货地址成功！"
		else
			flash[:error] = "请确定修改后的地址非空！"
		end
		redirect_to person_delivery_addresses_path
	end

	def destroy
		DeliveryAddress.delete(params[:id])
		flash[:success] = "删除收货地址成功！"
		redirect_to person_delivery_addresses_path
	end
end