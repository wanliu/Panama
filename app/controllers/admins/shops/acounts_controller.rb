#encoding: utf-8

class Admins::Shops::AcountsController < Admins::Shops::SectionController
	
	def bill_detail
		@people = current_user
	end

	def shop_info
		@user_checking = current_user.user_checking
		@shop = Shop.find_by(:name => params[:shop_id])
		@shop_auth = ShopAuth.new(@user_checking.attributes)
	end

	def edit_address
		@address = current_user.user_checking.address
		render layout: false
	end

	def update_address
		@address = current_user.user_checking.address
		@address.update_attributes(params[:address])
		if @address.valid?
			render json: { id: @address.id, address: @address.address_only }
		else
			render json: {}, :status => 403
		end
	end
end