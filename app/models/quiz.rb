class Quiz < ActiveRecord::Base
  belongs_to :course
  belongs_to :user

  attr_accessible :name, :question_ids, :test_code, :user_id, :course_id
end
