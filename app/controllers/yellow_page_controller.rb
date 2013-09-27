class YellowPageController < ApplicationController
	 layout "application"

	def index
		@seller_users = UserChecking.where(:checked => true, :service_id => 2)
		@buyer_users  = UserChecking.where(:service_id => 1)
		@new_users    =  UserChecking.order('created_at DESC').limit(15)

		respond_to do |format|
			format.html
			format.json{ render :json => { :seller_users => @seller_users,
				                           :buyer_users => @buyer_users,
				                           :new_users => @new_users }}
		end
	end

	def show
		@user = UserChecking.find(params[:id])
		respond_to do |format|
	      format.html # show.html.erb
	      # format.js { render "yellow_page/show" }
	      format.json { render json: @user }
	    end
	end
end
