#encoding: utf-8

ActiveAdmin.register Product do

  index do
    column :name
    column :properties do |product|
      properties_string = product.properties.map do |prop|
        "#{prop.name}: #{prop.property_type}< #{product.send(prop.name).inspect} >"
      end
      link = link_to "have #{ product.properties.size } propertys.", system_product_path(product)
      link + "   " + properties_string.to_s

    end
    column do |product|
      link_to "修改", edit_system_product_path(product)
    end
  end

  show do |product|
    div do
      panel("Product Base") do
        attributes_table_for(product) do
          attrbute_names = product.attributes.map { |attr, _| attr }
          attrbute_names.each do |column|
            row column
          end
        end
      end
    end

    div do
      panel("Product Properties") do
        attributes_table_for(product) do
          property_names = product.properties.map { |prop, _| prop.name }
          property_names.each do |column|
            row column
          end
        end
      end
    end
  end

  collection_action :new_plus do
    @product = Product.new
    class Product
      attr_accessor :categories
    end
  end

  member_action :properties do
    @product = Product.find(params[:id])
  end

  member_action :edit_plus do
    @product = Product.find(params[:id])
  end

  member_action :attach_properties, :method => :put do
    @product = Product.find(params[:id])
    @product.attach_properties!
    redirect_to system_product_path(params[:id])
  end

  action_item :only => :show do
    link_to 'Attach Properties', attach_properties_system_product_path(params[:id]), :method => :put
  end
end