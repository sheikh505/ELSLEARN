# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20170216121805) do

  create_table "answer_images", :force => true do |t|
    t.integer  "answer_id"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "answers", :force => true do |t|
    t.integer  "user_test_history_id"
    t.integer  "question_id"
    t.string   "answer_detail"
    t.integer  "marks"
    t.string   "remarks"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.string   "video_file_name"
    t.string   "video_content_type"
    t.integer  "video_file_size"
    t.datetime "video_updated_at"
    t.boolean  "reviewed",             :default => false
  end

  create_table "assignments", :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "board_degree_assignments", :force => true do |t|
    t.integer  "degree_id"
    t.integer  "board_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "board_question_assignments", :force => true do |t|
    t.integer  "question_id"
    t.integer  "board_degree_assignment_id"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "boards", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.boolean  "enable",     :default => false
  end

  create_table "bookrequests", :force => true do |t|
    t.string   "name"
    t.string   "author"
    t.string   "edition"
    t.string   "status"
    t.text     "reason"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "books", :force => true do |t|
    t.string   "name"
    t.string   "price"
    t.string   "description"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "author"
    t.integer  "course_id"
    t.integer  "degree_id"
  end

  create_table "ckeditor_assets", :force => true do |t|
    t.string   "data_file_name",                  :null => false
    t.string   "data_content_type"
    t.integer  "data_file_size"
    t.string   "data_fingerprint"
    t.integer  "assetable_id"
    t.string   "assetable_type",    :limit => 30
    t.string   "type",              :limit => 30
    t.integer  "width"
    t.integer  "height"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "ckeditor_assets", ["assetable_type", "assetable_id"], :name => "idx_ckeditor_assetable"
  add_index "ckeditor_assets", ["assetable_type", "type", "assetable_id"], :name => "idx_ckeditor_assetable_type"

  create_table "course_linkings", :force => true do |t|
    t.integer  "course_1"
    t.integer  "course_2"
    t.integer  "course_3"
    t.integer  "course_4"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "courses", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.boolean  "enable",     :default => false
  end

  create_table "degree_course_assignments", :force => true do |t|
    t.integer  "board_degree_assignment_id"
    t.integer  "course_id"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "degrees", :force => true do |t|
    t.string   "name"
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
    t.boolean  "enable",     :default => false
  end

  create_table "images", :force => true do |t|
    t.string   "alt",                 :default => ""
    t.string   "hint",                :default => ""
    t.string   "file_file_name"
    t.string   "file_content_type"
    t.integer  "file_file_size"
    t.datetime "file_updated_at"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
  end

  create_table "membership_plans", :force => true do |t|
    t.integer  "price"
    t.string   "paper"
    t.integer  "max_questions_allowed"
    t.text     "result_type"
    t.integer  "validity"
    t.integer  "other_course_amount"
    t.datetime "created_at",            :null => false
    t.datetime "updated_at",            :null => false
    t.string   "name"
  end

  create_table "news_feeds", :force => true do |t|
    t.text     "title"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "options", :force => true do |t|
    t.string   "statement"
    t.integer  "question_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.integer  "is_answer"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.integer  "flag"
  end

  create_table "packages", :force => true do |t|
    t.string   "name"
    t.integer  "price"
    t.integer  "degree_id"
    t.boolean  "mcq"
    t.boolean  "fill"
    t.boolean  "true_false"
    t.boolean  "descriptive"
    t.boolean  "past_paper"
    t.boolean  "instant_result"
    t.boolean  "teacher_review"
    t.boolean  "video_review"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.integer  "flag"
  end

  create_table "past_paper_histories", :force => true do |t|
    t.integer  "flag"
    t.string   "session"
    t.string   "year"
    t.string   "paper"
    t.string   "ques_no"
    t.integer  "question_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "course_id"
  end

  create_table "question_histories", :force => true do |t|
    t.integer  "user_id"
    t.integer  "question_id"
    t.string   "board_ids"
    t.string   "degree_ids"
    t.integer  "difficulty"
    t.integer  "topic_id"
    t.boolean  "is_approved"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "topic_ids"
    t.string   "difficulty_str"
  end

  create_table "question_quota", :force => true do |t|
    t.integer  "question_type"
    t.integer  "quota"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "questions", :force => true do |t|
    t.text     "statement"
    t.boolean  "deleted"
    t.integer  "test_id"
    t.integer  "topic_id"
    t.integer  "approval_status",   :default => 0
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
    t.string   "description"
    t.integer  "question_type"
    t.string   "instruction"
    t.string   "source"
    t.string   "author"
    t.integer  "difficulty"
    t.string   "workflow_state"
    t.string   "comments"
    t.integer  "course_linking_id"
    t.string   "varient"
    t.string   "topic_ids"
    t.string   "difficulty_ids"
    t.string   "degree_ids"
    t.integer  "marks",             :default => 1
  end

  create_table "quizzes", :force => true do |t|
    t.string   "name"
    t.string   "test_code"
    t.string   "question_ids"
    t.integer  "user_id"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
    t.integer  "course_id"
    t.boolean  "attempted",    :default => false
    t.float    "time_allowed"
    t.string   "topic_ids"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "teacher_courses", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.integer  "course_id"
    t.integer  "degree_id"
  end

  create_table "teacher_requests", :force => true do |t|
    t.integer  "teacher_code"
    t.integer  "student_id"
    t.string   "student_name"
    t.string   "student_email"
    t.string   "status"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "teacher_token"
  end

  create_table "tests", :force => true do |t|
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "name"
    t.string   "questionids"
    t.string   "question_ids"
    t.integer  "user_id"
    t.string   "test_code"
    t.integer  "course_id"
  end

  create_table "topic_linkings", :force => true do |t|
    t.integer  "topic_1"
    t.integer  "topic_2"
    t.integer  "topic_3"
    t.integer  "topic_4"
    t.integer  "course_linking_id"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "topics", :force => true do |t|
    t.string   "name"
    t.integer  "course_id"
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
    t.integer  "parent_topic_id"
  end

  create_table "user_addresses", :force => true do |t|
    t.string   "address"
    t.string   "state"
    t.string   "city"
    t.string   "zipcode"
    t.string   "coutry"
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "user_packages", :force => true do |t|
    t.integer  "package_id"
    t.datetime "validity"
    t.integer  "credit_left"
    t.integer  "user_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "plan"
    t.string   "name"
    t.integer  "course_id"
  end

  create_table "user_test_histories", :force => true do |t|
    t.string   "course"
    t.integer  "score"
    t.integer  "total"
    t.string   "code"
    t.integer  "user_id"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.integer  "board_id"
    t.integer  "degree_id"
    t.integer  "pastpaperflag"
    t.string   "mcq"
    t.string   "fill"
    t.string   "truefalse"
    t.string   "descriptive"
    t.integer  "year"
    t.string   "session"
    t.integer  "course_id"
    t.text     "topic_ids"
    t.string   "quiz_name"
    t.boolean  "is_live",          :default => false
    t.boolean  "video_review"
    t.integer  "teacher_id"
    t.string   "student_feedback"
    t.boolean  "reviewed",         :default => false
    t.integer  "total_questions"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0,  :null => false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "role"
    t.string   "phone"
    t.string   "name"
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "provider"
    t.string   "uid"
    t.string   "institute"
    t.integer  "degree_id"
    t.string   "student_amount"
    t.string   "degrees"
    t.string   "courses"
    t.integer  "membership_plan_id"
    t.string   "teacher_token"
    t.boolean  "free_plan_flag"
    t.string   "device_token"
    t.string   "test_permission_ids"
    t.boolean  "is_active"
    t.string   "review_permission_ids",  :default => ""
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  create_table "workflow_paths", :force => true do |t|
    t.integer  "course_id"
    t.integer  "degree_id"
    t.boolean  "is_complete", :default => true
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

end
