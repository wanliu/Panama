class Admins::ShopController < Admins::BaseController
  include WidgetUI::Rails::ControllerMethodsLoader

  widgets_binding do

    create_page :page do
      state :new, "app/views/admins/shop/contents/new"

      create_table :table

      create_search :search

      create_button :new_content do 
        on_click do
          replace "#page", {:widget => :page, :state => :display}, :new
        end
      end

      create_input :content_name do
      end

      create_content_select :choose_content do 
      end

      create_container :container, :widget => :choose_content do
        on_change do |evt|
          # debugger
          content = "#{evt[:value]}".to_sym
          widget("contents/#{content}", content).build(self) unless find_widget(content)
          replace "##{widget_id} .child", { :widget => content, :state => :display}
        end
      end
    end    
  end

  section :dashboard
  section :contents do
    shop = Shop.find(params[:shop_id])
    @contents = shop.contents
    # button :new do 
    #   page do
    #     @content = current_shop.contents.build
    #     simple_form @content do |f|
    #       f.input :name
    #       f.input :content_type 
    #       f.input :data
    #       f.submit 'submit'
    #       f.button 'cancel'
    #     end        
    #   end
    # end

    # input :search do |value|
    #   @contents = current_shop.contents.where(:name => value)
    # end

    # table :contents do
    #   @contents = current_shop.contents
    # end
  end

  section :categories
  section :menu
  section :components
  section :media
end