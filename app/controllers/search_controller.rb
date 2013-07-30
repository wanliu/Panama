class SearchController < ApplicationController

  layout "search"

  def users
    query_val = "%#{params[:q]}%"
    users = User.where("id<>#{current_user.id} and (login like ? or email like ?)", query_val, query_val).limit(params[:limit])
    respond_to do |format|
      _users = users.as_json.map do |u|
        u["value"] = u["login"]
        u
      end
      format.json{ render :json => _users }
    end
  end

  def products
    query = params[:q]
    s = Tire.search ["products", "shop_products"] do
        query do
          string "name:#{query}"
        end

        sort("_script" => {
            :script => "doc['_type'].value",
            :type   => "string",
            :order  => "desc"
          }, "_score" => {})

        # constant_score do
        #   query do
        #     string "name:#{query}"
        #   end

        #   boost 1.2
        # end
        size 30

        # analyzer　:standard
      end
    @results = s.results
    respond_to do |format|
      format.json { render :json => @results }
      format.html { render :products }
    end
  end

  def shop_products
    if current_user.shop
      query = params[:q]
      shop_id = current_user.shop.id
      s = ShopProduct.search2 do
        query do
          string "name:#{query} and seller.id:#{shop_id}"
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
end
