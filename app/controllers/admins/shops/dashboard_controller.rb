class Admins::Shops::DashboardController < Admins::Shops::SectionController

	def index
		redirect_to url_for(current_shop) + "/admins/shop_info"
	end
end
