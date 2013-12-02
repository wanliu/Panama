class SearchController < ApplicationController

  layout "search"

  def user_checkings
    query_val = "%#{params[:q]}%"
    @region = RegionCity.location_region(params[:area_id])
    if @region.nil?
      city_ids = params[:area_id]
    else
      city_ids = @region.region_cities_ids()
    end
    @user_checkings = UserChecking.users_checking_query.where("(sh.name like ? or (us.login like ? or us.email like ?)) and checked= true and ad.area_id in (?)",query_val,query_val,query_val,city_ids).limit(9)
    respond_to do |format|
      format.json{ render json: @user_checkings.as_json(:methods => [:shop, :user]) }
    end
  end

  def circles
    query_val = "%#{params[:q]}%"
    @circles = Circle.where("circles.name like ?",query_val)
    respond_to do |format|
      format.json { render json: @circles.as_json(
        methods: [:friend_count, :header_url]) }
    end
  end

  def shop_circles
    query_val = "%#{params[:q]}%"
    city_ids = city_ids(params[:area_id])
    @circles = Circle.joins("left join addresses as addr on addr.area_id = circles.city_id").select("distinct circles.* ").where("circles.name like ? and circles.city_id in (?) and circles.owner_type='Shop'",query_val,city_ids)

    my_friends = current_user.circle_all_friends.pluck("user_id")
    @friends = User.joins("right join circle_friends as cf on cf.user_id = users.id ").select("users.*, cf.circle_id as circle_id").where("cf.circle_id in (?) and users.id in (?) ",@circles.pluck("circles.id"), my_friends).limit(5)

    respond_to do |format|
      format.dialog { render "shop_circles.dialog", :layout => false }
    end
  end

  def users
    query_val = "%#{params[:q]}%"
    users = User.where("id<>#{current_user.id} and (login like ? or email like ?)", query_val, query_val).limit(params[:limit])
    respond_to do |format|
      format.json{ render :json => users.as_json(:methods => :value) }
    end
  end

  def all
    val = filter_special_sym(params[:q].gsub(/ /,''))
    if val.present?
      @results = Tire.search ["shop_products", "products", "ask_buys", "activities"] do
        query do
          boolean do
            must do
              filtered do
                filter :query, :query_string => {
                  :query => "title:#{val} OR name:#{val} OR primitive:#{val}",
                  :default_operator => "AND"
                }

                filter :terms, :_type => ["activity", "ask_buy", "shop_product", "product"]
              end
            end
          end
        end
        size 10

        sort{ by :_score, :desc }
      end.results
    end
    respond_to do |format|
      format.json{ render :json => @results || [] }
    end
  end

  def shop_products
    if current_user.shop
      query = filter_special_sym(params[:q])
      shop_id = current_user.shop.id
      products = ShopProduct.search2 do
        query do
          string "name:#{query} OR primitive:#{query}", :default_operator => "AND"
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
    conditions = get_coditions(q)
    s = Tire.search ["shop_products", "products", "ask_buys", "activities"] do
      from _from
      size _size

      query do
        boolean do
          must do
            filtered do
              if q[:title].present?
                val = conditions[:title].gsub(/ /,'')
                filter :query, :query_string => {
                  :query => "title:#{val} OR name:#{val} OR primitive:#{val}",
                  :default_operator => "AND"
                }
              end

              if q[:catalog_id].present?
                filter :terms, "category.id" => conditions[:catalog_id]
              end

              if q[:category_id].present?
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
              end if q[:properties].present?

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

          should do
            custom_score :script => :activitySort, :lang => :native do
              filtered do
                filter :term, :_type => :activity
              end
            end
          end

          should do
            custom_score :script => :askbuySort, :lang => :native do
              filtered do
                filter :term, :_type => :ask_buy
              end
            end
          end

          should do
            custom_score :script => :shopProductSort, :lang => :native do
              filtered do
                filter :term, :_type => :shop_product
              end
            end
          end

          should do
            custom_score :script => :productSort, :lang => :native do
              filtered do
                filter :term, :_type => :product
              end
            end
          end
        end
      end
      sort{ by :_score, :desc }
    end
    @results = deal_results(s.results)
    respond_to do |format|
      format.json{ render :json => @results }
    end
  end

  private
  def deal_results(results)
    rs = results.map do |result|
      if result.type == "activity"
        activity = Activity.find(result.id)
        result = result.to_hash.merge({
          is_start: activity.start_sale?,
          likes: activity.likes.exists?(current_user)
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
      when :title
        @@conditions[key] = filter_special_sym(q[key])
      else
        @@conditions[key] = q[key]
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

end
