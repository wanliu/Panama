class YellowPageController < ApplicationController
	 layout "application"

	def index
		@seller_users = UserChecking.where(:checked => true, :service_id => 2)
		@buyer_users  = UserChecking.where(:checked => true, :service_id => 1)
		@new_users    =  UserChecking.order('created_at DESC').limit(15)

		@address = Address.new
		respond_to do |format|
			format.html
			format.json{ render :json => { :seller_users => @seller_users,
										   :buyer_users => @buyer_users,
										   :new_users => @new_users,
										   :address => @address,
										   :hot_cities => @hot_cities }}
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


	def hot_city_name
		if params[:type] == "new_user"
			@hot_cities = Address.find( :all,
										:joins =>  "LEFT JOIN `cities` ON cities.id = area_id" ,
										:select => "count(*) as hot_score,area_id,cities.name",
										:conditions => {
										   :targeable_type => "UserChecking", 
										},
										:group => "area_id",
										:order => "hot_score DESC")
		else
			service_id = (params[:type] == "seller_user" ? 2 : 1)
			@hot_cities = Address.find_by_sql( ["select service_id,area_id,name,hot_score 
												from (select count(*) as hot_score,cities.name,addresses.targeable_id, area_id from
												addresses, cities where cities.id = addresses.area_id and addresses.targeable_type= 'UserChecking'  group by area_id) as temp,user_checkings 
												where temp.targeable_id = user_checkings.id and service_id = :service_id",{:service_id => service_id} ])
		end
		respond_to do |format|
		    format.html # show.html.erb
		    format.json { render json: @hot_cities }
		end
	end


	def search
		args = { :targeable_type =>"UserChecking"}
		if params[:address]
			p = params[:address]
			args.merge({ :province_id => p[:province_id], :city_id => p[:city_id],:area_id => p[:area_id]})
		else
			p = params[:args]
			args.merge({ :area_id => p[:area_id]})
		end
		address_ids = Address.where(args).pluck("targeable_id")
		if address_ids.length > 0 
			options = {:id => address_ids }
			unless p[:type] == "new_user"
				options.merge!({ :service_id => (p[:type] == "seller_user" ? 2 : 1) })
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
