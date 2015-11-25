class Course < ActiveRecord::Base
  has_many :degree_course_assignments
  has_many :board_degree_assignments, through: :degree_course_assignments
  has_many :topics
  has_many :books
  has_many :quizzes
  has_many :workflow_paths

  attr_accessible :name
end
