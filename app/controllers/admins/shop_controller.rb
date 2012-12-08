class Admins::ShopController < Admins::BaseController 

  section :dashboard
  section :contents do 
    button :new do 
      page do
        @content = current_shop.contents.build
        simple_form @content do |f|
          f.input :name
          f.input :content_type 
          f.input :data
          f.submit 'submit'
          f.button 'cancel'
        end        
      end
    end

    input :search do |value|
      @contents = current_shop.contents.where(:name => value)
    end

    table :contents do
      @contents = current_shop.contents
    end
  end
  section :categories
  section :menu
  section :components
  section :media

end