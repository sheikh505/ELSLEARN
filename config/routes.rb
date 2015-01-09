ExamsSystem::Application.routes.draw do
  resources :boards


  resources :topics do
    collection do
      get :get_courses
    end
  end


  resources :teacher do
    collection do
      get :get_courses
      get :teacher_courses
      post :course_register
    end
  end

  resources :books do
    collection do
      get :get_courses
    end
  end


  resources :questions do
    collection do
      get :get_courses
      get :get_ques
      get :add_questions
      get :get_tests
      get :render_view
      get :render_view_edit
      get :delete_ques
    end
  end



  get "home_page/index"
  get "home_page/get_courses" => 'home_page#get_courses'
  get "home_page/get_tests" => 'home_page#get_tests'
  get "home_page/user_graph" => 'home_page#user_graph'

  resources :tests do
    collection do
      get :get_courses
    end
  end



  resources :courses


  resources :degrees


  resources :roles



  root :to => "home_page#index"

  devise_for :users, controllers: {sessions: "users/sessions",
                                   :confirmations => "users/confirmations",
                                   :passwords => "users/passwords",
                                   :unlocks => "users/unlocks",
                                   :registrations => "users/registrations"

  }

# devise_for :user do
#   get 'users/sign_out' => 'users/sessions#destroy'
# end

  devise_scope :user do
    #root :to => "users/sessions#new"
    get "sign_up" => "users/registrations#new"
    get "sign_in" => "users/sessions#new"
    delete "sign_out" => "users/sessions#destroy"

  end

  post '/tinymce_assets' => 'tinymce_assets#create'
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

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
