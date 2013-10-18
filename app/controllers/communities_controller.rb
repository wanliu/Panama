class CommunitiesController < ApplicationController
	layout "communities"

	before_filter :login_and_service_required

	def index
		@city = city_by_ip(request.remote_ip)
		@address = Address.new({ province_id: @city.parent.id, city_id: @city.id })
		# return "/cities/#{cookies[:city]}/communities" unless cookies[:city].blank?
		# cookies[:city] = { 
		# 	value: @city.id, 
		# 	expires: 1.months.from_now }

		respond_to do |format|
			format.html
			format.json{ render :json => {
				:address => @address
			}}
		end
	end

	def city_index
		@new_users = UserChecking.joins("right join addresses as addr on addr.targeable_id = user_checkings.id ")
								 .where("user_checkings.checked = true and addr.area_id = ?", params[:city_id])
								 .group('user_checkings.id')
								 .order('created_at DESC')
								 .limit(15)

		@circles= Circle.joins("left join circle_friends as cf on circles.id=cf.id left join addresses as addr on addr.area_id = circles.city_id ")
						.where(:created_type => "advance",:city_id => params[:city_id])
						.select("circles.*, count(cf.id) as count")
						.group("circles.id")
						.order("count desc")
						.limit(10)

		@top_10_shops = Shop.joins("left join followings as follow on shops.id = follow.follow_id and follow.follow_type = 'Shop'")
							.select("shops.*, count(follow.id) as count")
							.group("shops.id")
							.order("count desc")
							.limit(10)
							
		@city = City.find(params[:city_id])
		@address = Address.new
		respond_to do |format|
			format.html
			format.json { render  :json =>{ :new_users => @new_users,
										    :circles => @circles,
										    :top_10_shops => @top_10_shops,
										    :city => @city,
										    :address => @address }}
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
