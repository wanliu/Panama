class ProductSearchController < ApplicationController
  before_filter :login_and_service_required

  def index
    query = filter_special_sym(params[:q])
    products = Product.search2 do
      query do
        string "name:#{query} OR primitive:#{query}", :default_operator => "AND"
      end
    end.results
    respond_to do |format|
      format.json { render json: products }
    end
  end
end