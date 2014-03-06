class ProductSearchController < ApplicationController
  before_filter :login_required

  def index    
    products = product_search(params[:q])
    if params[:shop_id].present?
      products = product_join_state(products, params[:shop_id])
    end
    respond_to do |format|
      format.json { render json: products }
    end
  end

  private
  def product_search(query)
    q = filter_special_sym(query)
    if q.present?
      Product.search2 do
        query do
          string "name:#{q} OR primitive:#{q} OR untouched:#{q}*", :default_operator => "AND"
        end
      end.results
    else
      []
    end
  end
end