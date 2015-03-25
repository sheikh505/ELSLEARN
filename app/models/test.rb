class Test < ActiveRecord::Base
  belongs_to :course
  belongs_to :user
  has_many :questions

  # attr_accessible :title, :body
  attr_accessible :degree_course_id, :test_code, :name, :user_id, :question_ids
end
