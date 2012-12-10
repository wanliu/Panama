class Admins::ShopController < Admins::BaseController 


  has_widgets do |root|
    root << widget(:table, :records => @contents)
    root << widget(:search)
    root << widget(:button)
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