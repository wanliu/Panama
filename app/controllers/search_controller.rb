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
    query = filter_special_sym(params[:q])
    val = query.gsub(/ /, "")
    s = Tire.search ["products", "shop_products", "activities", "ask_buys"] do
        query do
          boolean do
            should do
              string "*#{query}*", fields: ["first_name", "any_name", "first_title", "any_name"]
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

        size 30
      end
    @results = s.results
    respond_to do |format|
      format.json { render :json => @results }
      format.html { render :products }
    end
  end

  def shop_products
    debugger
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

  def activities
    query = filter_special_sym(params[:q])
    _size, _from = params[:limit], params[:offset]
    toDay = DateTime.now.midnight
    s = Tire.search ['activities', 'ask_buys'] do
      from _from
      size _size

      query do

        boolean do
          must_not do
            string "activity.status:0"
          end
          must do
            range "activity.start_time", {lte: toDay}
          end
          must do
            range "activity.end_time", {gt: toDay}
          end
        end
      end
      sort do
        by :created_at, 'desc'
      end

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
end
