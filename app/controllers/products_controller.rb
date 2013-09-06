class ProductsController < ApplicationController
  before_filter :login_and_service_required, except: :base_info

  layout "product"

  def show
    @product = Product.find(params[:id])
    @product_content = PanamaCore::Contents.fetch_for(@product, :show)
    @sale_options_content = PanamaCore::Contents.fetch_for(@product, :sale_options)
    @item = ProductItem.new(:product => @product,
                            :title   => @product.name,
                            :price   => @product.price,
                            :amount  => 1,
                            :shop_id => @product.shop_id)

    form_builder(@item)

    @product.prices_definition.each do |prop|
      @item.properties << prop
    end

    @item.property_items = @product.property_items

    @item.delegate_property_setup
    if params[:layout] == "false"
      render layout: false
    end
  end

  def base_info
    @product = Product.find(params[:id])
    respond_to do |format|
      format.json{ render :json => @product.as_json(:version_name => params[:version_name]) }
    end
  end

  protected

  def form_builder(record)
    register_value :form do
      simple_form_for(record, url: "" ) do |f|
        break f
      end
    end
  end
end
