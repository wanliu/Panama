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
    s = Tire.search ["products", "shop_products"] do
        query do
          boolean do
            must { string "*#{query}*", fields: ["first_name", "any_name", "name"] }
          end
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
    s = Activity.search2 :type => ['activity', 'ask_buy'] do
      from _from
      size _size
    end
    @results = s.results
    respond_to do |format|
      format.json{ render :json => @results }
    end
  end
end
