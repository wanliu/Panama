Panama::Application.routes.draw do

  # devise_for :admin_users, ActiveAdmin::Devise.config

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
      end

      collection do
        post "batch_create", :to => "people/transactions#batch_create", :as => :batch_create
      end

    end

    resources :topics, :controller => "people/topics" do
      collection do
        get "receives/:id", :to => "people/topics#receives"
        get "following"
      end
    end

    resources :communities, :controller => "people/communities" do
      collection do
        get "people"
      end
    end

    resources :circles, :controller => "people/circles" do
      collection do
        get "friends"
        get "addedyou"
        get "all_friends"
        post "/:id/join_friend/:user_id", :to => "people/circles#join_friend"
        delete "/:id/remove_friend/:user_id", :to => "people/circles#remove_friend"
        delete "circles_remove_friend/:user_id", :to => "people/circles#circles_remove_friend"
      end
    end

    resources :followings, :controller => "people/followings" do
      collection do
        post "user/:user_id" => "people/followings#user"
        post "shop/:shop_id" => "people/followings#shop"
        get :shops
      end
    end

    match "followers", :to => "people/followings#followers"

    resources :product_comments, :controller => "people/product_comments" do
    end

    resources :notifications,:except => :show, :controller => "people/notifications" do
      collection do
        get "/:id/enter", :to => "people/notifications#show"
      end
    end

    resources :cart, :controller => "people/cart"

  end



  match "mycart", :to => "people/cart#add_to_cart", :as => :add_to_cart, :via => [:post, :put]
  match "mycart/clear_list",:to => "people/cart#clear_list", :as => :clear_cart_list, :via => :post

  match '/system/logout', :to => 'system_sessions#destroy'

  # resources :system

  resources :comments do
    collection do
      post 'activity'
      post 'product'
      post 'topic'
      get 'new_activity'
      get 'new_product'
      get "index_activities"
      get "count"
    end
  end

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
    collection do
      get "topic_categories/:id", :to => "shops#topic_categories"
    end

    namespace :admins do
      resources :dashboard, :controller => "shops/dashboard"

      resources :contents, :controller => "shops/contents"

      resources :menu, :controller => "shops/menu"

      resources :categories, :controller => "shops/categories" do
        collection do
          get :category_children
          get :category_root
          get :category_search
          get :category_full_name
        end
      end

      resources :products, :controller => "shops/products" do
        collection do
          get :category_page
          get "additional_properties/:category_id",
              :to => "shops/products#additional_properties"
        end

      end

      resources :topics, :controller => "shops/topics" do
        collection do
          get :my_related
          get "category/:topic_category_id", :to => "shops/topics#category"
          get "receives/:id", :to => "shops/topics#receives"
        end
      end

      resources :circles, :controller => "shops/circles" do
        collection do
          get :friends
          get :all_friends
          get :followers
          post "/:id/join_friend/:user_id", :to => "shops/circles#join_friend"
          delete "/:id/remove_friend/:user_id", :to => "shops/circles#remove_friend"
          delete "circles_remove_friend/:user_id", :to => "shops/circles#circles_remove_friend"
        end
      end

      resources :communities, :controller => "shops/communities" do
        collection do
          get :people
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

      resources :followings, :controller => "shops/followings" do
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

  match "attachments", :to => "attachments#index"
  match "attachments/upload", :to => "attachments#upload", :via => :post
  match "attachments/:id", :to => "attachments#destroy", :via => :delete

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

  match 'propertie_item/:id', :to => 'propertie_item#destroy'

  root :to => 'activities#index'

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'

  ActiveAdmin.routes(self)
end
