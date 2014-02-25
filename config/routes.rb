Panama::Application.routes.draw do

  resources :answer_ask_buy do 
    member do
      post :create_order, :to => "answer_ask_buy#create_order"
    end
  end

  resources :shop_products do
    collection do
      get ":shop_id/search", :to => "shop_products#search"
    end
    member do
      post :buy, :to => "shop_products#buy"
      post :direct_buy, :to => "shop_products#direct_buy"
      post :delete_many, :to => "shop_products#delete_many"
      put :update_attribute, :to => "shop_products#update_attribute"
    end
  end

  # devise_for :admin_users, ActiveAdmin::Devise.config
  resources :after_signup
  resources :completing_people do
    member do
      post 'skip'
      get "edit_address"
      match "update_address"
    end
  end

  resources :catalog do
    member do
      get :products, :to => "catalog#products"
      get :categories_id, :to => "catalog#categories_id"
    end
  end

  resources :completing_shop do
    member do
      get "edit_address"
      match "update_address"
    end
  end

  resources :user_auths

  match "catalog/products"

  match "user_checkings/update_shop_auth", :to => "user_checkings#update_shop_auth", :via => :put
  match "user_checkings/upload_photo/:id", :to => "user_checkings#upload_photo", :via => :post

  match "people/:shop_name/invite_people", :to => "people#invite_people"
  match "people/:shop_name/show_invite/:login", :to => "people#show_invite"
  match "people/:login/update_user_auth", :to => "people#update_user_auth", :via => :put
  match "people/:shop_name/show_email_invite", :to => "people#show_email_invite"
  match "people/:shop_name/show_invite", :to => "people#agree_invite_user", :via => :post
  match "people/:shop_name/show_email_invite", :to => "people#agree_email_invite_user", :via => :post

  match "cities/:city_id/communities/search", :to => "communities#search", :via => :get
  match "cities/:city_id/communities", :to => "communities#city_index", :via => :get

  match "transaction/operate_url", :to => "transactions#operate_url"

  resources :communities do
    collection do
      get "hot_region_name", :to => "communities#hot_region_name"
      get "search", :to => "communities#search"
    end

    match "access_denied", :to => "communities/circles#access_denied"

    resources :circles, :only => [:index], :controller => "communities/circles" do
      collection do
        get :members
        put :update_circle
        post :share_circle
        post :up_to_manager
        post :low_to_member
        delete :remove_member
        delete :quit_circle
        delete :destroy_circle
        get ":category_id/category", :to => "communities/circles#category"
        post :join
        post :apply_join
      end
    end

    resources :notifications, :only => [:index, :show], :controller => "communities/notifications" do
      member do
        post :agree_join
        post :refuse_join
      end
    end

    resources :topics, :controller => "communities/topics" do
      member do
        get :init_comment
        get :comments
        post :create_comment
        get :participates
        post :participate
      end
    end

    resources :invite, :controller => "communities/invite" do
      member do
        post :agree_join
        post :refuse_join
      end
    end 

    resources :categories, :controller => "communities/categories" do
      member do
        get :topics
      end
    end
  end

  resources :people do

    member do
      get 'follow'
      get 'unfollow'
    end

    resources :withdraw_money, :controller => "people/withdraw_money" do 
      
    end

    resources :banks, :controller => "people/banks" do 
    end
    
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
        post "delay_sign", :to => "people/transactions#delay_sign"
        post 'transfer', :to => "people/transactions#transfer"
        get 'print', :to => "people/transactions#print"
        post "mark_as_read", :to => "people/transactions#mark_as_read"
        get :kuaiqian_receive
        match 'kuaiqian_payment', :via => [:get, :post]
        match 'test_payment', :via => [:get, :post]
        post :generate_token
        get :mini_item
        get :card
        get :operator
      end

      collection do
        post "batch_create", :to => "people/transactions#batch_create"
        get "completed", :to => "people/transactions#completed"
        get "unread_messages", :to => "people/transactions#unread_messages"
      end
    end

    resources :order_refunds, :controller => "people/order_refunds" do
      member do
        post "event(/:event)", :to => "people/order_refunds#event", :as => :trigger_event
        post 'update_delivery', :to => "people/order_refunds#update_delivery"
        get 'page', :to => "people/order_refunds#page"
        post 'update_delivery_price', :to => "people/order_refunds#update_delivery_price"
        get :mini_item
        get :card
      end
    end

    resources :delivery_addresses, :controller => "people/delivery_addresses" do
    end

    resources :direct_transactions, :controller => "people/direct_transactions" do
      member do
        get :dialog, :to => "people/direct_transactions#dialog"
        get :messages, :to => "people/direct_transactions#messages"
        post :send_message, :to => "people/direct_transactions#send_message"
        post :completed, :to => "people/direct_transactions#completed"
        get :page
        post :generate_token
        get :mini_item
        get :operator
      end
    end

    resources :recharges, :controller => "people/recharges", :only => [:index, :show] do 
      collection do 
        match :payment, :to => "people/recharges#payment", :via => [:get, :post]    
        get :test_payment
      end

      member do
        get :receive
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
        get :all_circles
      end
    end

    resources :circles, :controller => "people/circles" do
      collection do
        post :apply_join
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
        post "User/:user_id" => "people/followings#user"
        post "Shop/:shop_id" => "people/followings#shop"
        get :shops
      end
    end

    match "followers", :to => "people/followings#followers"

    resources :product_comments, :controller => "people/product_comments" do
      collection do
        get "/:order_id/order" => "people/product_comments#order"
      end
    end

    resources :notifications,:except => :show, :controller => "people/notifications" do
      member do
        get :enter, :to => "people/notifications#show"
        match :mark_as_read, :to => "people/notifications#mark_as_read"
      end
      collection do
        get :read_all, :to => "people/notifications"
        get :unreads, :to => "people/notifications#unreads"
        get :unread_count, :to => "people/notifications#unread_count"
      end
    end

    resources :cart, :controller => "people/cart" do
      member do
        post 'move_out_cart', :to => "people/cart#move_out_cart"
        post 'change_number', :to => "people/cart#change_number"
      end

      collection do
        post 'move_out', :to => 'people/cart#move_out'
      end
    end

    resources :ask_buy, :controller => "people/ask_buy"

    resources :activities, :controller => "people/activities" do
      collection do
        get "likes", :to => "people/activities#likes"
      end
    end

    match 'my_activity', :to => "people/activities#my_activity"
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

  resources :city do
    collection do
      get 'province'
    end
  end
  resources :delivery_types

  resources :activities do
    member do
      post 'share_activity'
      post 'like'
      post 'unlike'
      post 'to_cart'
      get 'buy'
    end
    collection do
      get 'tomorrow'
    end
  end

  namespace :activities do
    resources :auction do
      member do
        post 'join'
      end
    end
    resources :courage
    resources :focus do
      member do
        post 'join'
        post 'unjoin'
      end
    end
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
      get "followings"
      get "channels"
      post "upload_avatar/:id", :to => "users#upload_avatar"
    end
  end

  resources :contents, :except => :index

  resources :products, :except => :index do
    collection do 
      get "all_brand_name", :to => "products#all_brand_name"
    end
    member do
      get 'base_info'
    end
  end

  resources :ask_buy do
    member do
      post :comment, :to => "ask_buy#comment"
      post :join, :to => "ask_buy#join"
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
      get "dialogue/generate_and_display/:friend_id", :to => "chat_messages#generate_and_display"
      post "read/:friend_id", :to => "chat_messages#read"
    end
  end

  resources :receive_order_messages


  resources :category do
    member do
      get :products
      get :subtree_ids, :to => "category#subtree_ids"
    end
    collection do
      get "shop_products",  :to => "category#shop_products"
      get "filtered_brand", :to => "category#filtered_brand"
    end
  end

  # shop admins routes
  resources :shops, :except => :index do
    collection do
      get "topic_categories/:id", :to => "shops#topic_categories"
    end

    member do
      get "follow"
      get "unfollow"
      get "shop_circles"
    end

    namespace :admins do

      resources :dashboard, :controller => "shops/dashboard"

      resources :contents, :controller => "shops/contents"

      resources :menu, :controller => "shops/menu"

      resources :product_comments, :controller => "shops/product_comments" do
        member do
          post :reply, :to => "shops/product_comments#reply"
        end
      end

      resources :direct_transactions, :to => "shops/direct_transactions" do
        member do
          get :dialog, :to => "shops/direct_transactions#dialog"
          get :messages, :to => "shops/direct_transactions#messages"
          post :send_message, :to => "shops/direct_transactions#send_message"
          post :dispose, :to => "shops/direct_transactions#dispose"
          get :page
          post :generate_token
          get :mini_item
          get :operator
        end
      end

      resources :categories, :controller => "shops/categories" do
        collection do
          get :category_children
          get :category_root
          get :category_search
          get :category_full_name
        end
      end

      resources :banks, :controller => "shops/banks" do 

      end

      #resources :shop_banks, :controller => "shops/shop_banks"

      resources :products, :controller => "shops/products" do
        collection do
          get :category_page
          get "additional_properties/:category_id",
            :to => "shops/products#additional_properties"
        end
      end

      resources :shop_products, :controller => "shops/shop_products" do
      end

      resources :transactions, :controller => "shops/transactions" do
        member do
          get "page", :to => "shops/transactions#page"
          post "event(/:event)", :to => "shops/transactions#event", :as => :trigger_event
          post "dispose", :to => "shops/transactions#dispose"
          get "dialogue", :to => "shops/transactions#dialogue"
          post "send_message", :to => "shops/transactions#send_message"
          get "messages", :to => "shops/transactions#messages"
          put "update_delivery", :to => "shops/transactions#update_delivery"
          get "print", :to => "shops/transactions#print"
          put 'update_delivery_price', :to => "shops/transactions#update_delivery_price"
          post :generate_token
          get :mini_item
          get :card
          get :operator
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
          get  :people
          get  :settings
          get  :messages
          post :invite_people
          get "apply_join/:cn_id", :to => "shops/communities#apply_join"
          post "join_circle/:cn_id", :to => "shops/communities#join_circle"
          post "refuse_join/:cn_id", :to => "shops/communities#refuse_join"
        end
      end

      match "pending", :to => "shops/transactions#pending"
      match "complete", :to => "shops/transactions#complete"
      match "shop_info", :to => "shops/acounts#shop_info"
      post "create_address", :to => "shops/acounts#create_address"
      get "edit_address", :to => "shops/acounts#edit_address"
      match "update_address", :to => "shops/acounts#update_address"
      match "bill_detail", :to => "shops/acounts#bill_detail"
      match "apply_update", :to => "shops/acounts#apply_update"

      resources :order_refunds, :controller => "shops/order_refunds" do
        member do
          post "event(/:event)", :to => "shops/order_refunds#event", :as => :trigger_event
          post 'refuse_reason', :to => "shops/order_refunds#refuse_reason"
          get 'page', :to => "shops/order_refunds#page"
          get :mini_item
          get :card
          post :dispose
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

  # Search Engine
  match "search/user_checkings", :to => "search#user_checkings", :via => :get
  match "search/users", :to => "search#users"
  match "search/products", :to => "search#products"
  match "search", :to => "search#index"
  match "search/shop_products", :to => "search#shop_products", :via => :get
  match "search/shop_circles", :to => "search#shop_circles", :via => :get
  match "search/circles", :to => "search#circles", :via => :get
  match "search/all", :to => "search#all", :via => :get
  match "search/shops", :to => "search#shops", :via => :get
  match "search/circles", :to => "search#circles", :via => :get
  match "search/tomorrow", :to => "search#tomorrow", :via => :get


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
