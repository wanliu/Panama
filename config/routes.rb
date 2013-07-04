Panama::Application.routes.draw do

  # devise_for :admin_users, ActiveAdmin::Devise.config
  resources :after_signup
  resources :completing_people
  resources :completing_shop

  match "people/:shop_name/show_invite/:login", :to => "people#show_invite"
  match "people/:shop_name/show_email_invite", :to => "people#show_email_invite"
  match "people/:shop_name/show_invite", :to => "people#agree_invite_user", :via => :post
  match "people/:shop_name/show_email_invite", :to => "people#agree_email_invite_user", :via => :post

  resources :people do

    resources :transactions, :controller => "people/transactions" do
      member do
        get "page", :to => "people/transactions#page"
        post "event(/:event)", :to => "people/transactions#event", :as => :trigger_event
        put "base_info", :to => "people/transactions#base_info"
        put "notify", :to => "people/transactions#notify"
        put "done", :to => "people/transactions#done"
        get "dialogue", :to => "people/transactions#dialogue"
        post "send_message", :to => "people/transactions#send_message"
        get "messages", :to => "people/transactions#messages"
        post "get_delivery_price", :to => "people/transactions#get_delivery_price"
        post "refund", :to => "people/transactions#refund"
        post 'transfer', :to => "people/transactions#transfer"
      end

      collection do
        post "batch_create", :to => "people/transactions#batch_create", :as => :batch_create
      end
    end

    resources :order_refunds, :controller => "people/order_refunds" do
      member do
        post "event(/:event)", :to => "people/order_refunds#event", :as => :trigger_event
        post 'delivery_code', :to => "people/order_refunds#delivery_code"
      end
    end

    resources :addresses, :controller => "people/addresses" do
      
    end

    match 'recharges/ibank', :to => "people/recharges#ibank", :via => :post
    match 'recharges/remittance', :to => "people/recharges#remittance", :via => :post

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

    resources :cart, :controller => "people/cart" do
      member do
        post 'move_out_cart', :to => "people/cart#move_out_cart"
        post 'change_number', :to => "people/cart#change_number"
      end
    end

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
  resources :delivery_types

  resources :activities do
    member do
      post 'like'
      post 'unlike'
      post 'to_cart'
      post 'join'
    end
  end

  namespace :activities do
    resources :auction
    resources :courage
    resources :focus
    resources :package
    resources :score
  end

  get "transport/index"

  get "products/index"

  get "complete/index"

  get "pending/index"

  resources :users do
    collection do
      get "connect/:token", :to => "users#connect"
      get "disconnect/:id", :to => "users#disconnect"
    end
  end

  resources :contents, :except => :index

  resources :products, :except => :index do
    member do
      get 'base_info'
    end
  end

  resources :product_search
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
  resources :chat_messages do
    collection do
      post "dialogue/generate/:friend_id", :to => "chat_messages#generate"
      get "dialogue/display/:token", :to => "chat_messages#display"
      post "read/:friend_id", :to => "chat_messages#read"
    end
  end

  resources :receive_order_messages


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

      resources :transactions, :controller => "shops/transactions" do
        member do
          post "event(/:event)", :to => "shops/transactions#event", :as => :trigger_event
          post "dispose", :to => "shops/transactions#dispose"
          get "dialogue", :to => "shops/transactions#dialogue"
          post "send_message", :to => "shops/transactions#send_message"
          get "messages", :to => "shops/transactions#messages"
          put "delivery_code", :to => "shops/transactions#delivery_code"
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

      match "pending", :to => "shops/transactions#pending"
      match "complete", :to => "shops/transactions#complete"

      resources :order_refunds, :controller => "shops/order_refunds" do
        member do
          post "event(/:event)", :to => "shops/order_refunds#event", :as => :trigger_event
          post 'refuse_reason', :to => "shops/order_refunds#refuse_reason"
        end
      end

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

      resources :complaint, :controller => "shops/complaint"

      resources :transport, :controller => "shops/transport"

      resources :templates, :controller => "shops/templates"

      resources :receive_order_messages, :controller => "shops/receive_order_messages"

    end
  end

  resources :contact_friends do
    collection do
      get "join_friend/:friend_id", :to => "contact_friends#join_friend"
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
