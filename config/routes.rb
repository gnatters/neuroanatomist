Neuroanatomist::Application.routes.draw do
  
  
  namespace :admin do
    root :to => "base#index"
    resources :users
  end
    
  root :to => 'pages#home'
  match "/node:node_name"     => "pages#access_node",   :constraints => { :node_name  => /:.*/}
  match "/thing:thing_name"   => "pages#access_thing",  :constraints => { :thing_name => /:.*/}
  match "/quiz"               => "pages#quiz"
  match "/about"              => "pages#about"
  match "/contact"            => "pages#contact"
  match "/topics(/:node_name)"  => "pages#topics"
  
  match "/user" => "user#index"
  
  devise_for :users, :controllers => {:registrations => "registrations"}

  match "/nodes/preview" => "nodes#preview"
  resources :nodes
  resources :sections

  resources :bibliographies
  resources :resources
  resources :resource_types

  resources :tags
  resources :ratings

  resources :perspectives
  resources :region_styles
  
  
  namespace :ontology do
    root :to => "ontology#index"
    post "/ontology" => "ontology#create"
    get "/export" => "ontology#export"
    resources :types, :things, :relations, :facts
  end
  
  resources :shape_sets
  resources :shapes
  resources :meshes
  
  resources :regions
  resources :region_definitions
  resources :decompositions
  
  match "/vdata/:shape_set_id"        => "v_data#shape_set",    :constraints => { :shape_set_id => /\d+/ }
  match "/vdata/:shape_set_id/r:ids"  => "v_data#regions",      :constraints => { :shape_set_id => /\d+/, :ids => /:[\d,]*/ }
  match "/vdata/:shape_set_id/p:ids"  => "v_data#perspectives", :constraints => { :ids => /:[\d,]*/ }
  match "/vdata"                      => "v_data#defaults"
  match "/vdata_hashes"               => "v_data#check_hashes"
  match "/vdata_ids/:subject/:major_version"  => "v_data#shape_set_ids"
  match "/vdata_updates/:shape_set_id"        => "v_data#updates"
  
  match "/images/:file" => redirect {|params| "/assets/#{params[:file]}.#{params[:format]}" }
  
  
  mount Jax::Engine => "/jax" unless Rails.env == "production"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
