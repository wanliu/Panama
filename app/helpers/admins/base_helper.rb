module Admins
  module BaseHelper

    def side_bar(name)
      render :partial => "sidebar", :locals => { :name => name , :sections => controller.sections }
    end

    def admins_contents(record)
      if record.new_record?
        shop_admins_contents_path params[:shop_id]
      else
        shop_admins_content_path params[:shop_id], record
      end
    end

    def admins_template(record)
      if record.new_record?
        shop_admins_templates_path params[:shop_id]
      else
        shop_admins_template_path params[:shop_id], record.name
      end
    end

    def admins_categories(record)
      if record.new_record?
        shop_admins_categories_path params[:shop_id]
      else
        shop_admins_category_path params[:shop_id], record
      end
    end

    def admins_products(record)
      if record.new_record?
        shop_admins_products_path params[:shop_id]
      else
        shop_admins_product_path params[:shop_id], record
      end
    end

    def admin_active_section(name)
      content_for(:admin_siderbar) do
        name.to_s
      end
    end
  end
end