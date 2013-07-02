class ProductSearchController < ApplicationController
  before_filter :login_required

  def index
    # products = Redis::Search.complete("Product", params[:q]).first(10)
    q_string = "name:#{params[:q]}"
    
    s = Product.search2 do 
      query { string q_string }
    end
    products = s.results
    respond_to do |format|
      format.json { render json: products }
    end
  end
end