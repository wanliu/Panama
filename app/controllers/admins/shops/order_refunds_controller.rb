class Admins::Shops::OrderRefundsController < Admins::Shops::SectionController

	def index
		@refunds = OrderRefund.where(:seller_id => current_shop.id)
	end
end