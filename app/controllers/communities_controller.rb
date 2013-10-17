class CommunitiesController < ApplicationController
	layout "application"

	before_filter :login_and_service_required
	before_filter :current_city, :only => [:index]



	def ip_search(client_ip)
		# address = IPSearch.ip_query(client_ip)
		address = IPSearch.ip_query("124.228.76.190")
		if address.blank?
			[]
		else
			address_detail = address["content"]["address_detail"]
			province = address_detail["province"]
			city = address_detail["city"]
			province_id = City.where(:name => province).pluck("id")[0]
			city_id = City.find(province_id).children.find_by_name(city).id
			[province_id,city_id]
		end
	end

	def index
		address_ids = ip_search(request.remote_ip)

		@address_choice = Address.new({ province_id: address_ids[0], city_id: address_ids[1], area_id: "" })

		@new_users = UserChecking.where(:checked => true).order('created_at DESC').limit(15)

		@circles= Circle.where(:created_type => "advance")
						.joins("left join circle_friends as cf on circles.id=cf.id")
						.select("circles.*, count(cf.id) as count")
						.group("circles.id")
						.order("count desc")
						.limit(10)
		# @circles= Circle.where(:created_type => "advance").joins("left join circle_friends as cf on circles.id=cf.id left join cities as city on circles.city_id = ?", current_city_id).select("circles.*, count(cf.id) as count").group("circles.id").order("count desc").limit(10)

		@top_10_shops = Shop.joins("left join followings as follow on shops.id = follow.follow_id and follow.follow_type = 'Shop'")
							.select("shops.*, count(follow.id) as count")
							.group("shops.id")
							.order("count desc")
							.limit(10)

		@address = Address.new
		respond_to do |format|
			format.html
			format.json{ render :json =>{ :new_users => @new_users,
										  :address => @address,
										  :circles => @circles,
										  :top_10_shops => @top_10_shops,
										  :city => @current_city,
										  :address_choice => @address_choice }}
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
