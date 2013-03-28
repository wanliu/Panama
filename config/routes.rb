Panama::Application.routes.draw do

  # devise_for :admin_users, ActiveAdmin::Devise.config

  # faye_server '/realtime', timeout: 25 do
  #   map "/notification/**" => RealtimeNoticeController
  #   map default: :block
  #   class MockExtension
  #     def incoming(message, callback)
  #        callback.call(message)
  #     end
  #     def outgoing(message, callback)
  #         callback.call(message)
  #     end
  #   end
  #   add_extension(MockExtension.new)
  # end

  resources :people do
    collection do
      get ":shop_name/show_invite/:login", :to => "people#show_invite"
      get ":shop_name/show_email_invite", :to => "people#show_email_invite"
      post ":shop_name/show_invite", :to => "people#agree_invite_user"
      post ":shop_name/show_email_invite", :to => "people#agree_email_invite_user"
    end

    resources :transactions, :controller => "people/transactions" do
      member do
        post "event/:event", :to => "people/transactions#event", :as => :trigger_event
        post "batch_create", :to => "people/transactions#batch_create", :as => :batch_create
      end
    end

    resources :product_comments, :controller => "people/product_comments" do
    end

    resources :notifications,:except => :show, :controller => "people/notifications" do
      collection do
        get "/:id/enter", :to => "people/notifications#show"
      end
    end

    resources :comments, :controller => "people/comments" do
      collection do
        post 'activity'
        post 'product'
        get 'new_activity'
        get 'new_product'
        get "index_activities"
      end
    end

    resources :cart, :controller => "people/cart"

    member do
      post "add_to_cart", :to => "people/cart#add_to_cart", :as => :add_to_cart
      put "add_to_cart", :to => "people/cart#add_to_cart", :as => :add_to_cart
      post "clear_list", :to => "people/cart#clear_list", :as => :clear_cart_list
      # post "batch_create", :to => "people/transactions#batch_create", :as => :batch_create
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

  resources :users
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
          get "additional_properties/:category_id",
              :to => "shops/products#additional_properties"
        end

      end

      resources :transactions, :controller => "shops/transactions"

      match "pending", :to => "shops/transactions#pending"

      resources :employees, :controller => "shops/employees", :except => :destroy  do
        collection do
          post "invite", :to => "shops/employees#invite"
          get 'find_by_group', :to => "shops/employees#find_by_group"
          post "group_join_employee", :to => "shops/employees#group_join_employee"
          delete "group_remove_employee", :to => "shops/employees#group_remove_employee"
          delete "destroy/:user_id", :to => "shops/employees#destroy"
        end
      end

      resources :groups, :controller => "shops/groups" do
        collection do
          get "permissions/:id", :to => "shops/groups#permissions"
          post "check_permissions/:id", :to => "shops/groups#check_permissions"
        end
      end

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

  match "shops/:shop_id/admins/products/category/:shops_category_id",
    :to => "admins/shops/products#products_by_category"

  match "shops/:shop_id/admins/products/category/:shops_category_id/accept/:product_id",
    :to => "admins/shops/products#accept_product"


  match "shops/:shop_id/admins/", :to => "admins/shops/dashboard#index", as: :shop_admins
  resources :search do
    collection do
      get "users"
    end
  end


  # omniauth
  match '/auth/:provider/callback', :to => 'user_sessions#create'
  match '/auth/failure', :to => 'user_sessions#failure'

  match '/auth/admin/:provider/callback', :to => 'system_sessions#create'

  # Custom logout
  match '/logout', :to => 'user_sessions#destroy'
  # See how all your routes lay out with "rake routes"

  match 'vfs/:file_path/expansion', :to => 'vfs#expansion'
  match 'system/vfs/show_file', :to => 'vfs#show_file'
  match 'vfs/destroy_file', :to => 'vfs#destroy_file'
  post 'vfs/edit_file', :to => 'vfs#edit_file'
  post 'vfs/create_file', :to => 'vfs#create_file'

  root :to => 'activities#index'

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'

  ActiveAdmin.routes(self)
end
