class CommunitiesController < ApplicationController
	layout "application"

	def index
		@city = City.where(:name => params[:name]).first
		# @new_users = UserChecking.where(:checked => true).order('created_at DESC').limit(15)
		@new_users = UserChecking.order('created_at DESC').limit(10)
		@circles = Circle.where(:created_type => "advance")
						 .joins("left join circle_friends as cf on circles.id=cf.id")
						 .select("circles.*, count(cf.id) as count")
						 .order("count desc").limit(10)

		@top_10_circles = Shop.where(:follow_type => "Shop")
					  .joins("left join followings as follow on shops.id = follow.user_id")
					  .select("shops.*, count(follow.id) as followers")
					  .group("shops.id")
					  .order("followers desc").limit(10)

		@address = Address.new
		respond_to do |format|
			format.html
			format.json{ render :json =>{ :new_users => @new_users,
										  :address => @address,
										  :circles => @circles,
										  :top_10_circles => @top_10_circles,
										  :city => @city }}
		end
	end

	def show
		@user = UserChecking.find(params[:id])
		respond_to do |format|
		  format.html # show.html.erb
		  format.json { render json: @user }
		end
	end


	def hot_city_name
		@hot_cities = Address.find( :all,
									:joins =>  "LEFT JOIN `cities` ON cities.id = area_id" ,
									:select => "count(*) as hot_score,area_id,cities.name",
									:conditions => {
									   :targeable_type => "UserChecking", 
									},
									:group => "area_id",
									:order => "hot_score DESC")
		respond_to do |format|
		    format.html # show.html.erb
		    format.json { render json: @hot_cities }
		end
	end

	def search
		address = params[:address]
		address.merge!({:targeable_type =>"UserChecking"})
		address_ids = Address.where(address).pluck("targeable_id")
		@users = _search(address_ids)
		respond_to do |format|
			format.html
			format.json{ render json: @users}
		end
	end

	def _search(address_ids)
		if address_ids.length > 0 
			options = {:id => address_ids,:checked => true }
			@users = UserChecking.where(options).order("created_at desc").limit(15)
		else
			@users = []
		end
	end
end
