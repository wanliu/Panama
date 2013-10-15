class ProductSearchController < ApplicationController
  before_filter :login_and_service_required

  def index
    query = filter_special_sym(params[:q])
    s = Product.search2 do
      query do
        boolean do
          must {
            filtered do
              filter :query, :query_string => {
                :query => "name:#{query} OR primitive:#{query}*",
                :default_operator => "AND"
              }
            end
          }
        end
      end
    end
    products = s.results
    respond_to do |format|
      format.json { render json: products }
    end
  end
end