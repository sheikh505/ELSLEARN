class DegreeCourseAssignment < ActiveRecord::Base
  belongs_to :course
  belongs_to :degree
  has_many :tests
  has_many :books
  has_many :teacher_courses
  has_many :users, through: :teacher_courses
  # attr_accessible :title, :body
  attr_accessible :course_id, :degree_id
end
