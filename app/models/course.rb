class Course < ActiveRecord::Base
  has_many :degree_course_assignments,:dependent => :destroy
  has_many :board_degree_assignments, through: :degree_course_assignments
  has_many :topics, :dependent => :destroy
  has_many :books
  has_many :quizzes, :dependent => :destroy
  has_many :workflow_paths, :dependent => :destroy

  attr_accessible :name, :enable
end
