Panama::Application.routes.draw do

  # devise_for :admin_users, ActiveAdmin::Devise.config

  faye_server '/realtime', timeout: 25 do
    map "/notification/**" => RealtimeNoticeController
    map default: :block
    class MockExtension
      def incoming(message, callback)
         callback.call(message)
      end
      def outgoing(message, callback)
          callback.call(message)
      end
    end
    add_extension(MockExtension.new)
  end

  resources :people do
    resources :cart, :controller => "people/cart"
    resources :transactions, :controller => "people/transactions" do
      member do
        post "event/:event", :to => "people/transactions#event", :as => :trigger_event
      end
    end

    resources :notifications, :controller => "people/notifications" do

    end

    resources :comments, :controller => "people/comments" do
      collection do
        post 'activity'
        post 'product'
        get 'new_activity'
        get 'new_product'
      end
    end

    member do
      post "add_to_cart", :to => "people/cart#add_to_cart", :as => :add_to_cart
      put "add_to_cart", :to => "people/cart#add_to_cart", :as => :add_to_cart
      post "clear_list", :to => "people/cart#clear_list", :as => :clear_cart_list
      post "batch_create", :to => "people/transactions#batch_create", :as => :batch_create
    end
  end

  match '/system/logout', :to => 'system_sessions#destroy'

  # resources :system

  resources :city
  resources :addresses

  resources :activities

  get "transport/index"

  get "products/index"

  get "complete/index"

  get "pending/index"

  resources :users, :except => :index
  resources :contents, :except => :index

  resources :products, :except => :index

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

  resources :shops, :except => :index do

    namespace :admins do
      match "attachments", :to => "shops/attachments#index"
      match "attachments/upload", :to => "shops/attachments#upload", :via => :post
      match "attachments/destroy/:id", :to => "shops/attachments#destroy", :via => :delete

      resources :dashboard, :controller => "shops/dashboard"

      resources :contents, :controller => "shops/contents"

      resources :menu, :controller => "shops/menu"

      resources :categories, :controller => "shops/categories"

      resources :products, :controller => "shops/products" do
        collection do
          get :category_page
        end
      end

      resources :transactions, :controller => "shops/transactions"

      match "pending", :to => "shops/transactions#pending"

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


  match "shops/:shop_id/admins/", :to => "admins/shops/dashboard#index", as: :shop_admins
  resources :search


  # omniauth
  match '/auth/:provider/callback', :to => 'user_sessions#create'
  match '/auth/failure', :to => 'user_sessions#failure'

  match '/auth/admin/:provider/callback', :to => 'system_sessions#create'

  # Custom logout
  match '/logout', :to => 'user_sessions#destroy'
  # See how all your routes lay out with "rake routes"

  root :to => 'activities#index'

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'

  ActiveAdmin.routes(self)
end
