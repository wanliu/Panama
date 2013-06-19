require 'panama_core/contents'

PanamaCore::Contents.config do

  root '/panama'
  template 'templates/:action.html.erb'

  default_action :show


  category do
    default_additional_properties
    default_sale_options
    default_product_show
    default_additional_properties_admins

    each do
      template 'templates/category_:id,_:action.html.erb'
      additional_properties :transfer => :default_additional_properties
      additional_properties_admins :transfer => :default_additional_properties_admins
      sale_options :transfer => :default_sale_options
      product_show :transfer => :default_product_show
    end
  end

  shop do
    root '/_shops/:shop_name'

    each do
      index
    end

  end

  product do
    # root '/panama'

    each do
      show :transfer => 'category#product_show', :transfer_method => :category
      sale_options :transfer => 'category#sale_options', :transfer_method => :category
    end
  end
end