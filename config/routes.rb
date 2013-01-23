Panama::Application.routes.draw do

  resources :people, :key => :login do
    resources :cart, :controller => "people/cart"
    member do 
      post "add_to_cart", :to => "people/cart#add_to_cart", :as => :add_to_cart
      put "add_to_cart", :to => "people/cart#add_to_cart", :as => :add_to_cart
      post "clear_list", :to => "people/cart#clear_list", :as => :clear_cart_list  
    end
  end

  resources :activities

  get "transport/index"

  get "products/index"

  get "complete/index"

  get "pending/index"

  resources :users
  resources :contents
  resources :newsletter_receivers

  resources :products

  # resources :shops do
  #   scope :module => "admins" do
  #     match "admins", :to => 'shop#index'
  #     match "admins/:section_name", :to => 'shop#section'
  #     # resources :shop, :path => "admins", :as => "admins" do 
  #     #   collection :section
  #     # end
  #   end
  # end
  # 

  resources :category
  # shop admins routes

  resources :shops, :key => :name  do 
    namespace :admins do 
      resources :dashboard, :controller => "shops/dashboard"
    end
  end

  resources :shops, :key => :name do 
    namespace :admins do 
      resources :contents, :controller => "shops/contents"
    end
  end

  resources :shops do 
    namespace :admins do 
      resources :menu, :controller => "shops/menu"
    end
  end

  resources :shops do 
    namespace :admins do 
      resources :categories, :controller => "shops/categories"
    end
  end

  match "shops/:shop_id/admins/products/category/:category_id", 
    :to => "admins/shops/products#products_by_category"

  match "shops/:shop_id/admins/products/category/:category_id/accept/:product_id", 
    :to => "admins/shops/products#accept_product"

  resources :shops do 
    namespace :admins do 
      resources :products, :controller => "shops/products" 
    end
  end

  resources :shops do 
    namespace :admins do 
      resources :pending, :controller => "shops/pending"
    end
  end

  resources :shops do 
    namespace :admins do 
      resources :complete, :controller => "shops/complete"
    end
  end

  resources :shops do 
    namespace :admins do 
      resources :complaint, :controller => "shops/complaint"
    end
  end

  resources :shops do 
    namespace :admins do 
      resources :transport, :controller => "shops/transport"
    end
  end

  resources :shops do 
    namespace :admins do 
      resources :templates, :controller => "shops/templates"
    end
  end  

  match "shops/:shop_id/admins/", :to => "admins/shops/dashboard#index"


  # match "shops/:shop_id/admins/contents", :to => "admins/shops/contents"

  # match "shops/:shop_id/admins/", :to => "admins/shops#index"

  resources :search
  
  
  # omniauth
  match '/auth/:provider/callback', :to => 'user_sessions#create'
  match '/auth/failure', :to => 'user_sessions#failure'
  
  # Custom logout
  match '/logout', :to => 'user_sessions#destroy'
  # See how all your routes lay out with "rake routes"

  root :to => 'activities#index'

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
