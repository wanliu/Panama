Panama::Application.routes.draw do

  resources :contents
  resources :newsletter_receivers

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

  # shop admins routes
  resources :shops do 
    namespace :admins do 
      resources :dashboard, :controller => "shops/dashboard"
    end
  end

  resources :shops do 
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

  resources :shops do 
    namespace :admins do 
      resources :templates, :controller => "shops/templates"
    end
  end  

  match "shops/:shop_id/admins/", :to => "admins/shops#index"


  # match "shops/:shop_id/admins/contents", :to => "admins/shops/contents"

  # match "shops/:shop_id/admins/", :to => "admins/shops#index"

  resources :search
  
  root :to => 'welcome#index'
  
  # omniauth
  match '/auth/:provider/callback', :to => 'user_sessions#create'
  match '/auth/failure', :to => 'user_sessions#failure'
  
  # Custom logout
  match '/logout', :to => 'user_sessions#destroy'
  # See how all your routes lay out with "rake routes"


  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
