Panama::Application.routes.draw do

  resources :contents
  resources :newsletter_receivers

  resources :shops do
    scope :module => "admins" do
      match "admins", :to => 'shop#index'
      match "admins/:section_name", :to => 'shop#section'
      # resources :shop, :path => "admins", :as => "admins" do 
      #   collection :section
      # end
    end
  end

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
