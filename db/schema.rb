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

ActiveRecord::Schema.define(:version => 20160122154731) do

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
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
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
    t.integer  "degree_id"
    t.integer  "course_id"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "author"
  end

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
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "degree_course_assignments", :force => true do |t|
    t.integer  "board_degree_assignment_id"
    t.integer  "course_id"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "degrees", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
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

  create_table "past_paper_histories", :force => true do |t|
    t.integer  "flag"
    t.string   "session"
    t.string   "year"
    t.string   "paper"
    t.string   "ques_no"
    t.integer  "question_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "question_histories", :force => true do |t|
    t.integer  "user_id"
    t.integer  "question_id"
    t.integer  "board_id"
    t.integer  "degree_id"
    t.integer  "difficulty"
    t.integer  "topic_id"
    t.boolean  "is_approved"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.integer  "topic_linking_id"
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
  end

  create_table "quizzes", :force => true do |t|
    t.string   "name"
    t.string   "test_code"
    t.string   "question_ids"
    t.integer  "user_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.integer  "course_id"
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
    t.integer  "user_id"
    t.string   "test_code"
    t.integer  "course_id"
    t.string   "question_ids"
    t.string   "questionids"
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

  create_table "user_test_histories", :force => true do |t|
    t.string   "course"
    t.integer  "score"
    t.integer  "total"
    t.string   "code"
    t.integer  "user_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.integer  "board_id"
    t.integer  "degree_id"
    t.integer  "pastpaperflag"
    t.integer  "mcq"
    t.integer  "fill"
    t.integer  "truefalse"
    t.integer  "descriptive"
    t.integer  "year"
    t.string   "session"
    t.integer  "course_id"
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
