require 'panama_core/contents'

PanamaCore::Contents.config do

  root '/panama'
  template 'templates/:action.html.erb'

  category do

    default_additional_properties

    each do
      template 'templates/category_:id,_:action.html.erb'
      additional_properties :transfer => :default_additional_properties
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