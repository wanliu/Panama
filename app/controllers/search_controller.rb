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
    #_size, _from= params[:limit], params[:offset]
    query = filter_special_sym(params[:q])
    val = query.gsub(/ /, "")
    s = Tire.search ["products", "shop_products", "activities", "ask_buys"] do
      # from _from
      # size _size

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
              #filter :range, :end_time => {gt: toDay}
              #filter :range, :start_time => {lte: toDay}
              filter :term, :_type => "activity"
              filter :term, :status => 1
              filter :terms, {"category.id" => conditions[:catalog_id]} if q[:catalog_id].present?
            end
          end
          should do
            filtered do
              filter :term, :_type => "ask_buy"
              filter :terms, {"category.id" => conditions[:catalog_id]} if q[:catalog_id].present?
            end
          end
          should do
            filtered do
              filter :term, :_type => "product"
              filter :terms, {"category.id" => conditions[:catalog_id]} if q[:catalog_id].present?
            end
          end
          should do
            filtered do
              filter :term, :_type => "shop_product"
              filter :terms, {"category.id" => conditions[:catalog_id]} if q[:catalog_id].present?
            end
          end
        end
      end

      sort("_script" => {
        :script => "
          var analyze = function(){
            this.one_houre = 3600000;
            this.to_day = new Date();
            this.to_day_ms = this.to_day.getTime();
          }

          analyze.prototype.activity = function(){
            var start_time = new Date(doc.start_time.value),
                end_time = new Date(doc.end_time.value),
                total = (doc.like.value * 5) + (doc.participate.value * 100),
                end_time_ms = end_time.getTime(),
                start_time_ms = start_time.getTime();

            if(total<=0) total = 1;
            if(start_time > this.to_day){
              return total/((start_time_ms-to_day_ms)/this.one_houre);
            }else if(start_time < this.to_day && end_time < this.to_day){
              return total/((this.to_day_ms-end_time_ms)/this.one_houre);
            }else{
              return total/((this.to_day_ms-start_time_ms)/this.one_houre);
            }
          }

          analyze.prototype.ask_buy = function(){
            var c = new Date(doc.created_at.value)
            return 10/((this.to_day_ms - c.getTime())/this.one_houre);
          }

          analyze.prototype.product = function(){
            return 0.01;
          }

          analyze.prototype.shop_product = function(){
            return 0.0001;
          }
          an = new analyze();
          an[doc._type.value]();",
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
    if cl.present?
      Category.descendants(cl.categories.pluck("categories.ancestry")).pluck("id")
    else
      []
    end
  end

  @@conditions = {}
  def get_coditions(q)
    q.keys.each do |key|
      key = key.to_sym
      case key
      when :catalog_id
        catalog_condition(key, q)
      else
        @@conditions[key] = q[key]
      end
    end
    @@conditions
  end

  def catalog_condition(key, q)
    _key = "#{key}_#{q[key]}".to_sym
    unless @@conditions.key?(_key)
      @@conditions[key] = @@conditions[_key] = query_catalog(q[key])
    end
  end
end
