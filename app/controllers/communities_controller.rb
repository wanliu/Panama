class CommunitiesController < ApplicationController
	layout "application"

	before_filter :login_and_service_required
	before_filter :current_city, :only => [:index]

	def index
		# @new_users = UserChecking.where(:checked => true).order('created_at DESC').limit(15)
		@new_users = UserChecking.order('created_at DESC').limit(10)

		@circles= Circle.where(:created_type => "advance")
						.joins("left join circle_friends as cf on circles.id=cf.id")
						.select("circles.*, count(cf.id) as count")
						.group("circles.id")
						.order("count desc")
						.limit(10)

		@top_10_shops = Shop.joins("left join followings as follow on shops.id = follow.follow_id and follow.follow_type = 'Shop'")
							.select("shops.*, count(follow.id) as count")
							.group("shops.id")
							.order("count desc")
							.limit(10)

		@current_city = City.find(2028)
		ancestor_ids = @current_city.ancestor_ids
    	@address = Address.new({ province_id: ancestor_ids[1], city_id: @current_city.id })

    	if params[:city_name].blank?
    		render_url = "index"
    	else
    		render_url = "city_index"
    	end
		respond_to do |format|
			format.html { render render_url }
			format.json { render render_url, :json =>{ :new_users => @new_users,
										  :address => @address,
										  :circles => @circles,
										  :top_10_shops => @top_10_shops,
										  :city => @current_city }}
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

	def current_city
		@current_city = City.where(:name => params[:name]).first
	end
end
