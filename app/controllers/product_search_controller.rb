class ProductSearchController < ApplicationController
  before_filter :login_and_service_required

  def index
    # products = Redis::Search.complete("Product", params[:q]).first(10)
    s = Product.search2 "name:#{params[:q]}"
    products = s.results
    respond_to do |format|
      format.json { render json: products }
    end
  end
end