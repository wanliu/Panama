Panama::Application.routes.draw do

  resources :people, :key => :login do
    resources :cart, :controller => "people/cart"
    resources :transactions, :controller => "people/transactions"
    
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
  
  resources :shops, :key => :name do 
    
    namespace :admins do
      match "attachments", :to => "shops/attachments#index"
      match "attachments/upload", :to => "shops/attachments#upload", :via => :post
      match "attachments/destroy/:id", :to => "shops/attachments#destroy", :via => :delete

      resources :dashboard, :controller => "shops/dashboard"

      resources :contents, :controller => "shops/contents"

      resources :menu, :controller => "shops/menu"

      resources :categories, :controller => "shops/categories" 
      
      resources :products, :controller => "shops/products"

      resources :pending, :controller => "shops/pending"    

      resources :complete, :controller => "shops/complete"

      resources :complaint, :controller => "shops/complaint" 

      resources :transport, :controller => "shops/transport"

      resources :templates, :controller => "shops/templates"
    end
  end  


  match "shops/:shop_id/admins/products/category/:category_id", 
    :to => "admins/shops/products#products_by_category"

  match "shops/:shop_id/admins/products/category/:category_id/accept/:product_id", 
    :to => "admins/shops/products#accept_product"


  match "shops/:shop_id/admins/", :to => "admins/shops/dashboard#index"

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
