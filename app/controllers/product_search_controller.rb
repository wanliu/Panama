class ProductSearchController < ApplicationController
  before_filter :login_required

  def index
    products = Redis::Search.complete("Product", params[:q]).first(params[:limit])
    respond_to do |format|
      format.json { render json: products.map{|p| p["value"] = p["title"];p } }
    end
  end
end