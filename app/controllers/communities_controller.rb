class CommunitiesController < ApplicationController

	layout "communities"

	before_filter :login_and_service_required, :except => [:index_url]

	def index_url
		name = params[:name]
		@circle = Circle.find_by(:name => name)
		render :json => { url: community_circles_path(@circle) }		
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
		city_ids = city_ids(params[:city_id])
		@new_users = UserChecking.joins("left join addresses as addr on addr.id = user_checkings.address_id ")
														 .where("user_checkings.checked = true and addr.area_id in (?)", city_ids)
														 .group('user_checkings.id')
														 .order('created_at DESC')
														 .limit(30)	

		my_friends = current_user.circle_all_friends.pluck("user_id")

		@circles = Circle.joins("left join circle_friends as cf on circles.id=cf.circle_id left join addresses as addr on addr.area_id = circles.city_id")
										 .where("owner_type = 'Shop' and circles.city_id in (?) ", city_ids)
										 .select("circles.*, count(cf.id) as count")
										 .group("circles.id")
										 .order("count desc")
										 .limit(9)

		@friends = User.joins("right join circle_friends as cf on cf.user_id = users.id ")
									 .select("users.*, cf.circle_id as circle_id")
									 .where("cf.circle_id in (?) and users.id in (?)",@circles.pluck("circles.id"), my_friends)
									 .limit(4)

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
												    :address => @address,
												    :region => @region }}
		end
	end

	def hot_region_name
		@hot_cities = Region.joins("left join region_cities as rc on regions.id=rc.region_id left join addresses as ad on rc.city_id=ad.area_id left join user_checkings as uc on uc.address_id=ad.id")
												.select("regions.*, count(uc.id) as count")
												.order("count desc")
												.group("rc.region_id")

		respond_to do |format|
			format.html # show.html.erb
			format.json { render json: @hot_cities }
		end
	end

	def search
		city_ids = Region.find(params[:region_id]).region_cities_ids()
		@user_checkings = UserChecking.joins("left join addresses as addr on user_checkings.address_id=addr.id ")
																  .where("addr.area_id in (?) and user_checkings.checked=true ",city_ids)
																  .group("user_checkings.id")
																  .order("user_checkings.created_at desc")
							 
		respond_to do |format|
			format.html
			format.json{ render json: @user_checkings.as_json(:methods => [:shop, :user]) }
		end
	end
end