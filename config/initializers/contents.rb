require 'panama_core/contents'

PanamaCore::Contents.config do

  root '/panama'
  template 'templates/:action.html.erb'



  category do
    default_additional_properties

    default_sale_options

    each do
      template 'templates/category_:id,_:action.html.erb'
      additional_properties :transfer => :default_additional_properties
      sale_options :transfer => :default_sale_options
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
      sale_options :transfer => 'category#sale_options', :transfer_method => :category
    end
  end
end