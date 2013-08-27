class ProductSearchController < ApplicationController
  before_filter :login_and_service_required

  def index
    query = filter_special_sym(params[:q])
    s = Product.search2 do
      query do
        boolean do
          should { string "*#{query}*", fields: ["first_name", "any_name", "primitive"] }
        end
      end
    end
    products = s.results
    respond_to do |format|
      format.json { render json: products }
    end
  end
end