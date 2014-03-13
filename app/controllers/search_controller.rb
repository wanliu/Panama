class SearchController < ApplicationController

  layout "search"

  def user_checkings
    query_val = "%#{params[:q]}%"
    @region = RegionCity.location_region(params[:area_id])
    city_ids = @region.nil? ? params[:area_id] : @region.region_cities_ids()
    @results = UserChecking.users_checking_query.where("(sh.name like ? or (us.login like ? or us.email like ?)) and checked= true and ad.area_id in (?)",query_val,query_val,query_val,city_ids).limit(9)

    @user_checkings = @results.map do |user_checking|
      r = user_checking.as_json
      user = user_checking.user
      r[:is_followed] = user.is_seller? ? current_user.is_follow_shop?(user.shop.id) : current_user.is_follow_user?(user.id)
      r
    end

    respond_to do |format|
      format.json{ render json: @user_checkings }
    end
  end

  def shops
    @results = shops_search(params[:q][:query])
    respond_to do |format|
      format.json{ render :json => @results }
    end
  end

  def circles
    friend_ids = current_user.circle_all_friends.pluck("user_id")
    @results = circles_search(params[:q][:query]).map do |result|      
      s = result.as_json
      circle = Circle.find(result.id)
      s[:isOwner] = circle.is_owner_people?(current_user)
      s[:isJoin] = circle.is_member?(current_user)
      s[:friend_count] = circle.friend_count
      # s[:friends] = circle.friends.where(:user_id => friend_ids).limit(4)
      # s[:isSeller] = circle.owner_type == "Shop"
      s
    end
    respond_to do |format|
      format.json { render json: @results }
    end
  end

  def shop_circles
    query_val = "%#{params[:q]}%"
    city_ids = city_ids(params[:area_id])
    @circles = Circle.joins("left join addresses as addr on addr.area_id = circles.city_id")
                     .select("distinct circles.* ")
                     .where("circles.name like ? and circles.city_id in (?) and circles.owner_type='Shop'",query_val,city_ids)

    my_friends = current_user.circle_all_friends.pluck("user_id")
    @friends = User.joins("right join circle_friends as cf on cf.user_id = users.id ")
                   .select("users.*, cf.circle_id as circle_id")
                   .where("cf.circle_id in (?) and users.id in (?) ",@circles.pluck("circles.id"), my_friends).limit(5)

    respond_to do |format|
      format.dialog { render "shop_circles.dialog", :layout => false }
    end
  end

  def users
    @results = users_search(params[:q][:query])
    respond_to do |format|
      format.json{ render :json => @results }
    end
  end

  def all
    @results = case params[:search_type]
    when "users"
      users_search(params[:q])
    when "circles"
      circles_search(params[:q])
    when "shops"
      shops_search(params[:q])
    else
      multi_index(params[:q])
    end
    respond_to do |format|
      format.json{ render :json => @results }
    end
  end

  def shop_products
    if current_user.shop
      query = filter_special_sym(params[:q])
      shop_id = current_user.shop.id
      products = ShopProduct.search2 do
        query do
          boolean do 
            must do 
              filtered do 
                filter :query, :query_string => {
                  :query => "name:#{query} OR primitive:#{query} OR untouched:#{query}*",
                  :default_operator => "AND"
                }
                filter :term, "seller.id" => shop_id
              end
            end
          end
        end
      end.results
    else
      products = []
    end
    respond_to do |format|
      format.json { render json: products }
    end
  end

  def index
    _size, _from, q = params[:limit], params[:offset], (params[:q] || {})    

    activity_score = custom_score_script(:activitySort, :activity)
    ask_buy_score = custom_score_script(:askbuySort, :ask_buy)
    shop_product_score = custom_score_script(:shopProductSort, :shop_product)
    product_score = custom_score_script(:productSort, :product)

    _query = condition_query(q)

    @results = Tire.search ["ask_buys", "activities", "shop_products", "products"] do
      from _from
      size _size

      query do
        boolean do
          must &_query  
          should &activity_score
          should &ask_buy_score
          should &shop_product_score
          should &product_score          
        end
      end
      sort{ by :_score, :desc }
    end.results
    respond_to do |format|
      format.json{ render :json => deal_results(@results) }
    end
  end

  def tomorrow
    _size, _from = params[:limit], params[:offset]
    time = DateTime.now.tomorrow.midnight
    @results = Activity.search2 do 
      from _from
      size _size
      query do 
        boolean do 
          must do 
            range :start_time, :from => time, :to => (time.tomorrow - 1.second)
          end
        end
      end
    end.results
    respond_to do |format|
      format.json{ render :json => deal_results(@results) }
    end
  end

  private
  def deal_results(results)
    rs = results.map do |result|
      if result.type == "activity"
        activity = Activity.find(result.id)        
        followed_id = activity.shop.followers.find_by(:user_id => current_user.id).try(:id)
        result = result.to_hash.merge({
          is_start: activity.start_sale?,
          likes: activity.likes.exists?(current_user),
          followed: activity.shop.followers.exists?(:user_id => current_user.id),
          is_self: activity.shop.user.eql?(current_user),
          followed_id: followed_id,
          setup_time: activity.setup_time
        })
      end
      result
    end
  end

  def query_catalog(catalog_id)
    cl = Catalog.find_by(:id => catalog_id)
    cl.present? ? cl.category_ids : []
  end

  def query_category(category_id)
    c = Category.find_by(:id => category_id)
    c.present? ? c.subtree_ids : []
  end

  @@conditions = {}
  def get_coditions(q)
    q.keys.each do |key|
      key = key.to_sym
      case key
      when :catalog_id
        condition_stores(key, q[key]) do
          query_catalog(q[key])
        end
      when :category_id
        condition_stores(key, q[key]) do
          query_category(q[key])
        end
      when :query
        @@conditions[key] = filter_special_sym(q[key])
      else
        @@conditions[key] = filter_special_sym(q[key])
      end
    end
    @@conditions
  end

  def condition_stores(key, val, &block)
    _key = "#{key}_#{val}".to_sym
    unless @@conditions.key?(_key)
      @@conditions[_key] = yield
    end
    @@conditions[key] = @@conditions[_key]
  end

  def custom_score_script(_script, _type)
    lambda do |should| 
      should.custom_score :script => _script, :lang => :native do
        filtered do
          filter :term, :_type => _type
        end
      end
    end
  end

  def condition_query(options = {})
    conditions = get_coditions(options)

    lambda do |must|      
      must.filtered do
        if options[:query].present?
          val = conditions[:query].gsub(/ /,'')
          filter :query, :query_string => {
            :query => "title:#{val} OR name:#{val} OR primitive:#{val} OR untouched:#{val}*",
            :default_operator => "AND"
          }
        end

        if options[:catalog_id].present?
          filter :terms, "category.id" => conditions[:catalog_id]
        end
        
        if options[:category_id].present?
          filter :terms, "category.id" => conditions[:category_id]
        end

        conditions[:properties].each do |key, val|
          filter :or, [{
            :and => [{
              :terms => {
                "product.properties.#{val['name']}" => val["values"]
              }
            },{
              :terms => {
                :_type => ["ask_buy", "activity"]
              }
            }]
          },{
            :and => [{
              :terms => {
                "properties.#{val['name']}" => val["values"]
              }
            },{
              :terms => {
                :_type => ["shop_product", "product"]
              }
            }]
          }]
        end if options[:properties].present?

        filter :or, [{
          :and => [{
            :term => {
              :_type => "activity",
              :status => Activity.statuses[:access]
            }
          }]
        },{
          :and => [{
            :terms => {
              :_type => ["ask_buy", "shop_product", "product"]
            }
          }]
        }]
      end
      
    end
  end

  def multi_index(val)
    _size, _from, val = params[:limit], params[:offset], filter_special_sym(val.gsub(/ /,''))
    
    results = Tire.search ["shop_products", "products", "ask_buys", "activities"] do
      size _size || 10
      from _from || 0

      query do
        boolean do
          must do
            filtered do
              filter :query, :query_string => {
                :query => "title:#{val} OR name:#{val} OR primitive:#{val} OR untouched:#{val}*",
                :default_operator => "AND"
              }

              filter :terms, :_type => ["activity", "ask_buy", "shop_product", "product"]
            end
          end
        end
      end     

      sort{ by :_score, :desc }
    end.results if val.present?
    results || []
  end

  def users_search(query_val)
    _size, _from, query_val = params[:limit], params[:offset], filter_special_sym(query_val)
    results = []
    results = User.search2 do 
      size _size || 10
      from _from || 0

      query do 
        boolean do 
          must do 
            filtered do 
              filter :or, :filters => [{
                :query => {
                  :query_string => {
                    :query => "login:#{query_val} OR login.primitive:#{query_val} OR login.untouched:#{query_val}*",
                    :default_operator => "AND"
                  }
                }
              },{
                :query => {
                  :query_string => {
                    :query => "address:#{query_val} OR address.primitive:#{query_val} OR address.untouched:#{query_val}*",
                    :default_operator => 'AND'
                  }
                }
              },{
                :query => {
                  :query_string => {
                    :query => "email:#{query_val}*",
                    :default_operator => 'AND' 
                  }
                }
              }]
            end
          end
        end
      end
    end.results if query_val.present?
    results
  end

  def circles_search(query_val)
    _size, _from, query_val = params[:limit], params[:offset], filter_special_sym(query_val)
    results = []
    results = Circle.search2 do 
      size _size || 10
      from _from || 0

      query do 
        boolean do 
          must do 
            filtered do           

              filter :or, :filters => [{
                :query => {
                  :query_string => {
                    :query => "name:#{query_val} OR name.primitive:#{query_val} OR name.untouched:#{query_val}*",
                    :default_operator => "AND"
                  }                  
                }
              },{
                :query =>  {
                  :query_string => {
                    :query => "address:#{query_val} OR address.primitive:#{query_val} OR address.untouched:#{query_val}*",
                    :default_operator => "AND"
                  }
                }
              }]
            end
          end
        end
      end
    end.results if query_val.present?
    results
  end

  def shops_search(query_val)
    _size, _from, query_val = params[:limit], params[:offset], filter_special_sym(query_val)
    results = []
    results = Shop.search2 do 
      size _size || 10
      from _from || 0

      query do 
        boolean do 
          must do 
            filtered do               
              filter :or, :filters => [{
                :query => {
                  :query_string => {
                    :query => "name: #{query_val} OR name.primitive:#{query_val} OR name.untouched:#{query_val}*",
                    :default_operator => "AND" 
                  }
                }
              },{
                :query => {
                  :query_string => {
                    :query => "address:#{query_val} OR address.primitive:#{query_val} OR address.untouched:#{query_val}*",
                    :default_operator => "AND"
                  }
                }
              }]
            end
          end
        end
      end
    end.results if query_val.present?
    results
  end
end
