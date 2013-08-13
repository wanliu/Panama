class ProductSearchController < ApplicationController
  before_filter :login_and_service_required

  def index
    # products = Redis::Search.complete("Product", params[:q]).first(10)
    query = params[:q].gsub(/[\+\-\*\/\.\,]/, "")
    s = Product.search2 "name:#{query}"
    products = s.results
    respond_to do |format|
      format.json { render json: products }
    end
  end
end