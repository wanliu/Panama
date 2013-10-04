class SearchController < ApplicationController

  layout "search"

  def users
    query_val = "%#{params[:q]}%"
    users = User.where("id<>#{current_user.id} and (login like ? or email like ?)", query_val, query_val).limit(params[:limit])
    respond_to do |format|
      format.json{ render :json => users.as_json(:methods => :value) }
    end
  end

  def products
    _size, _from= params[:limit], params[:offset]
    query = filter_special_sym(params[:q])
    val = query.gsub(/ /, "")
    s = Tire.search ["products", "shop_products", "activities", "ask_buys"] do
      from _from
      size _size

      query do
        boolean do
          should do
            string "*#{query}*", fields: ["first_name", "any_name", "first_title", "any_title"]
          end
          should do
            string "*#{val}*", :fields => ["name", "title"]
          end
        end
      end

      sort("_script" => {
          :script => "doc['_type'].value",
          :type   => "string",
          :order  => "desc"
        }, "_score" => {})
    end
    @results = s.results
    respond_to do |format|
      format.json { render :json => @results }
      format.html { render :products }
    end
  end

  def shop_products
    if current_user.shop
      query = filter_special_sym(params[:q])
      shop_id = current_user.shop.id
      s = ShopProduct.search2 do
        query do
          boolean do
            must { string "*#{query}*", fields: ["first_name", "any_name", "name"] }
            must { string "seller.id:#{shop_id}" }
          end
        end
      end
      products = s.results
    else
      products = []
    end
    respond_to do |format|
      format.json { render json: products }
    end
  end

  def index
    _size, _from, q = params[:limit], params[:offset], (params[:q] || {})
    toDay = DateTime.now.midnight
    conditions = get_coditions(q)
    s = Tire.search ['activities', 'ask_buys', 'shop_products', 'products'] do
      from _from
      size _size

      query do
        boolean do
          should do
            filtered do
              if q[:title].present?
                val = conditions[:title].gsub(/ /,'')
                filter :query, :query_string => {
                  :query => "*#{val}*",
                  :fields => ["first_name", "any_name", "first_title", "any_title", "name", "title"]
                }
              end
              filter :terms, :_type => ["activity", "ask_buy", "shop_product", "product"]
              if q[:catalog_id].present?
                filter :terms, {"category.id" => conditions[:catalog_id]}
              end

              if q[:category_id].present?
                filter :terms, {"category.id" => conditions[:category_id]}
              end
            end
          end
        end
      end

      sort("_script" => {
        :script => "global_sort",
        :type   => "number",
        :lang   => "js",
        :order  => "desc"
      }, "_score" => {})
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
