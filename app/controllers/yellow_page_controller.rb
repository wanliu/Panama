class YellowPageController < ApplicationController
	 layout "application"

	def index
		@seller_users = UserChecking.where(:checked => true, :service_id => 2)
		@buyer_users  = UserChecking.where(:service_id => 1)
		@new_users    =  UserChecking.order('created_at DESC').limit(15)
		@address = Address.new
		respond_to do |format|
			format.html
			format.json{ render :json => { :seller_users => @seller_users,
				                           :buyer_users => @buyer_users,
				                           :new_users => @new_users,
				                           :address => @address }}
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


	def search
		p = params[:address]
		user_checking_ids = Address.where(:targeable_type =>"UserChecking", :province_id => p[:province_id], :city_id => p[:city_id],:area_id => p[:area_id]).pluck("id")
		if user_checking_ids.length > 0 
			options ={:id => user_checking_ids }
			unless p[:type] == "new_user_form"			
				options.merge({ :service_id => (p[:type] == "seller_user_form" ? 2 : 1) })
			end			
			@users = UserChecking.where(options).order("created_at desc").limit(15)
		else
			@users = []
		end
		respond_to do |format|
			format.html
			format.json{ render json: @users}
		end
	end
end
