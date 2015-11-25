class DegreeCourseAssignment < ActiveRecord::Base
  belongs_to :course
  belongs_to :board_degree_assignment


  has_many :teacher_courses
  has_many :users, through: :teacher_courses
  # attr_accessible :title, :body
  attr_accessible :course_id, :board_degree_assignment_id
end
