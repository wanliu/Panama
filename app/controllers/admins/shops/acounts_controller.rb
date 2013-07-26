#encoding: utf-8
#账户
class Admins::Shops::AcountsController < Admins::Shops::SectionController
	
	def bill_detail
		@people = current_user
	end

	def shop_info
		@user_checking = current_user.user_checking
	    @shop = Shop.find_by(:name => params[:shop_id])
	    @shop_auth = ShopAuth.new(@user_checking.attributes)
	end
end