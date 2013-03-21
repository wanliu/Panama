class People::ProductCommentsController < People::BaseController
	before_filter :login_required

	def index
		@transactions = current_user.transactions
	end
end
