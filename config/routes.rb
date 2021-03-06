ExamsSystem::Application.routes.draw do
  resources :news_feeds


  mount Ckeditor::Engine => '/ckeditor'

  get "/topic_linkings/fetch_topic_linkings" => "topic_linkings#fetch_topic_linkings"

  resources :topic_linkings do
    collection do
      post :get_course_link
      get :get_topic_course_link
    end
  end


  resources :course_linkings
  resources :news_feeds
  resources :ckeditor, controller: 'ckeditor/'


  resources :membership_plans

  get "/questions/fetch_courses" => "questions#fetch_courses"
  get "/questions/fetch_details" => "questions#fetch_details"
  get "/questions/fetch_ques" => "questions#fetch_ques"
  get "/questions/fetch_course" => "questions#fetch_course"
  get "workflow_paths/fetch_reviews" => "workflow_paths#fetch_reviews"
  get "/topics/fetch_courses" => "topics#fetch_courses"
  get "/topics/fetch_table" => "topics#fetch_table"


  get "workflow_paths" => "workflow_paths#index"
  get "workflow_paths/toggle_workflow" => "workflow_paths#toggle_workflow"
  get "user" => "teacher#index"

  get 'auth/:provider/callback' => 'sessions#create'
  get 'logout' => 'sessions#destroy'

  get "user/new" => "teacher#new"
  post "user/save_result"
  get "user/my_profile"
  get "user/progress"
  put 'user/update_password'
  post "user/request_teacher"
  get "user/get_courses_by_degree_id"
  get "user/dashboard"
  get "user/ReTakeTest"
  get "user/manage_courses" => "user#manage_courses"
  get "/teachers/fetch_users" => "teacher#fetch_users"


  put "/user/update_courses" => "user#update_courses"

  delete "user.:id" => "teacher#destroy"

  get "home_page/user/my_profile" => "user#my_profile"
  get "home_page/checkout_form" => "home_page#checkout_form"
  get "/home_page/receipt" => "home_page#receipt"

  put "user/update"
  get "/courses/get_courses_by_degree_id"

  get "/boards/manage_boards" => "boards#manage_boards"
  get "/degrees/manage_degrees" => "degrees#manage_degrees"

  get "/course_linkings/manage_course_linkings" => "course_linkings#manage_course_linkings"
  get "/courses/manage_courses" => "courses#manage_courses"

  get "/courses/fetch_courses" => "courses#fetch_courses"
  get "/quizzes/fetch_courses" => "quizzes#fetch_courses"
  get "/quizzes/fetch_quizzes" => "quizzes#fetch_quizzes"

  get "/topics/fetch_topics" => 'topics#fetch_topics'

  resources :boards


  resources :topics do
    collection do
      get :get_courses
      get :get_topics
    end
  end


  resources :teacher do
    collection do
      get :get_courses
      get :teacher_courses
      post :course_register
      get :accept_student
      get :reject_student

    end

  end





  resources :books do
    collection do
      get :get_courses
    end
  end

  resources :services, except: [:show] do
    collection do
      post :sign_in
      get :get_all_boards
      get :get_all_degrees
      get :is_questions_exists
      get :fetch_questions
      get :get_lookup_data
      get :is_test_exists
      get :get_questions_by_test_code
      get :get_options_by_question_id
      get :verify_answers
      get :get_courses_by_teacher
      get :get_questions
      get :get_els_questions
      get :quiz
      post :create_quiz
      get :get_quiz_list
      get :get_student_quiz_list
      get :get_live_score_list
      get :live_score_details
      get :get_topics
      get :verify_answers_web
      get :show_quiz
      post :upload_image
      get :fetch_teacher_list
      get :fetch_quizzes
      get :fetch_answers
      post :save_remarks
      post :upload_video
      post :comment_feedback
      get :reviewed_quiz
      get :submit_feedback
      get :finish_review
      get :quizzes_list
      get :get_test_history_details
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
      get :get_limit
      get :demo
      get :questions_approval
      get :approve_question
      get :next_question
      get :previous_question
      post :approve_by_teacher
      post :past_paper_history_param
      get :past_paper_history_param_edit
      post :reject_by_teacher
      get :reject_question
      post :reject_question
      get :add_comment_to_question
      get :get_questions_by_status
      get :get_question_details_for_approval
      get :questions_exits
      put :update_topic
      get :remove_option
      get :questions_detail
      get :get_question_detail
      get :enable_question_review
      get :get_course_linking
      get :get_topic_course_link
      get :get_all_topics_from_topic_linking
      get :rejected_questions
    end
  end


  get "home_page/index"
  get "home_page/get_courses" => 'home_page#get_courses'
  get "home_page/get_degrees" => 'home_page#get_degrees'
  get "home_page/get_tests" => 'home_page#get_tests'
  get "home_page/instructions" => 'home_page#instructions'
  post "home_page/instructions" => 'home_page#instructions'
  post "home_page/quiz" => 'home_page#quiz'
  get "home_page/quiz" => 'home_page#quiz'
  get "home_page/next_ques" => 'home_page#next'
  get "home_page/user_graph" => 'home_page#user_graph'
  get "home_page/get_notes_courses" => 'home_page#notes_courses'
  get "home_page/get_notes" => 'home_page#get_notes'
  get "home_page/create_user_registration" => "home_page#create_user_registration"
  post "home_page/sign_in_user" => "home_page#sign_in_user"
  get "home_page/add_user_test" =>  "home_page#add_user_test"
  get "home_page/is_user_signed_in" => "home_page#is_user_signed_in"
  get "home_page/demo" => "home_page#demo"
  get "admin_panel" => "home_page#admin_panel"
  get "home_page/save_data" => 'home_page#save_data'
  get "home_page/save_answer" => 'home_page#save_answer_to_session'
  get "home_page/get_answer" => 'home_page#get_answer_from_session'
  get "aboutUs" => 'home_page#about_us'
  get "pricing" => 'home_page#pricing'
  get "try_it" => 'home_page#try_it'
  post "home_page/get_topic" => 'home_page#get_topic'
  get "how_it_works" => 'home_page#how_it_works'
  get "testimonials" => 'home_page#testimonials'
  get "home_page/assign_member_ship_plan" => "home_page#assign_member_ship_plan"
  post "home_page/checkout" => "home_page#checkout"

  get "home_page/get_varients"
  get "home_page/get_backup"
  get "home_page/payments" => "home_page#payments"
  post "/homepage/set_access" => "home_page#set_access"
  get "/home_page/questions/questions_detail" => "questions#questions_detail"
  post "/home_page/get_details" => "home_page#get_details"
  get "/homepage/check_student_package" => "home_page#check_student_package"
  post "/homepage/check_package" => "home_page#check_package"
  get "/home_page/fetch_teachers" => "home_page#fetch_teachers"

  resources :tests do
    collection do
      get :get_courses
      get :get_questions
    end
  end
  resources :quizzes do
    collection do
      get :get_courses
      get :get_questions
      get :get_els_questions
      get :test_exists
      get :get_questions_by_course
      get :get_topics
      get :get_next_question
    end
  end

  get "/home_page/get_session", :to => 'home_page#get_session'

  resources :courses


  resources :degrees


  resources :roles



  root :to => "home_page#index"

  delete "/user/delete_package", to: "user#delete_package"

  get "/user/add_course", to: "user#add_course"

  get "/user/fetch_packages", to: "user#fetch_packages"

  get "/user/buy", to: "user#buy"

  get "/user/purchase", to: "user#purchase"

  devise_for :users, :controllers=> {:sessions=> "users/sessions",
                                   :confirmations => "users/confirmations",
                                   :passwords => "users/passwords",
                                   :unlocks => "users/unlocks",
                                   :registrations => "users/registrations",
                                   :omniauth_callbacks => "users/omniauth_callbacks"


  }


# devise_for :user do
#   get 'users/sign_out' => 'users/sessions#destroy'
# end

  devise_scope :user do
    #root :to => "users/sessions#new"
    get "sign_up" => "users/registrations#new"
    get "sign_in" => "users/sessions#new"
    delete "sign_out" => "users/sessions#destroy"
    put "users/save_form_2" => "users/registrations#save_form_2"
    get "/user_exists" => "users/registrations#user_exists"
    post "/save_form_1" => "users/registrations#save_form_1"
    post "/save_form_2" => "users/registrations#save_form_2"
    post "/save_form_3" => "users/registrations#save_form_3"
    post "/registration" => "users/registrations#registration"
    get "/registration" => "users/registrations#registration"
  end

  post '/tinymce_assets' => 'tinymce_assets#create'

  get "/student/fetch_image" => "teacher#fetch_image"
  post "/student/upload_video" => "teacher#upload_video"
  get "/student_test" => "teacher#student_test"

  post "/save_remarks" => "teacher#save_remarks"
  get "/user/test_reviews" => "user#test_reviews"
  get "/user/quiz_answers" => "user#quiz_answers"
  get "/student/show_answer" => "user#show_answer"

  get "new_students" => "teacher#new_students"
  get "manage_students" => "teacher#manage_students"
  get "/check_quiz" => "teacher#check_quiz"

  get "/student/review_question" => "teacher#review_question"
  post "/student/submit_feedback" => "user#submit_feedback"
  get "/comment_feedback" => "teacher#comment_feedback"
  get "/get_teachers" => "home_page#get_teachers"
  post "/teachers/finish_review" => "teacher#finish_review"
  post "/home_page/upload_image" => "home_page#upload_image"
  post "/student/upload_image" => "teacher#upload_image"
  get "/teachers/reviewed_quizzes" => "teacher#reviewed_quizzes"
  get "/teachers/video_reviewed_quizzes" => "teacher#video_reviewed_quizzes"
  get "/teachers/preview_reviewed_quiz" => "teacher#preview_reviewed_quiz"
  get "/teachers/preview_question" => "teacher#preview_question"
  get "/teachers/next_image" => "teacher#next_image"
  get "/home_page/remove_image" => "home_page#remove_image"

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
