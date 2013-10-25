class CommunitiesController < ApplicationController
	layout "communities"

	before_filter :login_and_service_required

	def location_region(city_id)
		@region = RegionCity.find_by(:city_id => city_id).region
		city_ids = []
		@region.region_cities.each do |c|
			city_ids << c.city_id
		end 
		city_ids
	end

	def index
		if !cookies[:city_id].blank?
			redirect_to "/cities/#{cookies[:city_id]}/communities"
		else
			@city = city_by_ip(request.remote_ip)
			@address = Address.new({ province_id: @city.parent.id, city_id: @city.id })
			respond_to do |format|
				format.html
				format.json{ render :json => {
					:address => @address
				}}
			end
		end
	end

	def city_index
		city_ids = location_region(params[:city_id])
		@new_users = UserChecking.joins("left join addresses as addr on addr.id = user_checkings.address_id ")
								 .where("user_checkings.checked = true and addr.area_id in (?)", city_ids)
								 .group('user_checkings.id')
								 .order('created_at DESC')
								 .limit(15)

		my_circles_ids = current_user.circles.pluck("id")
		my_friends = CircleFriends.where(:circle_id => my_circles_ids).select("distinct user_id").pluck("user_id")


		@circles = Circle.joins("left join circle_friends as cf on circles.id=cf.circle_id left join addresses as addr on addr.area_id = circles.city_id")
						.where("created_type = 'advance' and circles.city_id in (?) ", city_ids)
						.select("circles.*, count(cf.id) as count")
						.group("circles.id")
						.order("count desc")
						.limit(9)

		@friends = User.joins("right join circle_friends as cf on cf.user_id = users.id ").select("users.*, cf.circle_id as circle_id").where("cf.circle_id in (?) and users.id in (?)",@circles.pluck("circles.id"), my_friends).limit(3)

		@top_10_shops = Shop.joins("left join followings as follow on follow.follow_id = shops.id left join addresses as addr on shops.address_id = addr.id")
		 	.where("follow.follow_type='Shop' and addr.area_id in (?)", city_ids)
		 	.select("shops.*,count(follow.id) as count")
		 	.group("shops.id")
		 	.order("count desc")
		 	.limit(10)

		@city = City.find(params[:city_id])
		cookies[:city_id] = { 
			value: @city.id, 
			expires: 1.months.from_now }
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
		  format.json{ render json: @user }
		end
	end

	def hot_city_name
		@hot_cities = Address.joins("left join cities as c on c.id=addresses.area_id")
							 .select("count(addresses.area_id) as count,c.name,addresses.area_id")
							 .group("addresses.area_id")
							 .order("count desc")
							 .limit(8)



					# Region.joins("right join region_cities as rg on rg.region_id=regions.id left join cities ")
		respond_to do |format|
			format.html # show.html.erb
			format.json { render json: @hot_cities }
		end
	end

	def search
		@users = UserChecking.joins("left join addresses as addr on user_checkings.address_id=addr.id")
							 .where("addr.area_id=?",params[:address][:area_id])
							 .group("user_checkings.id")
							 .order("user_checkings.created_at desc")
		respond_to do |format|
			format.html
			format.json{ render json: @users}
		end
	end
end