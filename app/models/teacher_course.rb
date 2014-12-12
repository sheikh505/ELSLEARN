class TeacherCourse < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :user
  belongs_to :degree_course_assignment
  attr_accessible :degree_course_assignment_id, :user_id
end
