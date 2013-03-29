require 'panama_core/contents'

PanamaCore::Contents.config do

  root '/panama'
  template 'templates/:name.html.erb'

  category do

    default_additional_properties

    each do
      additional_properties
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
      sale_options
    end
  end
end