class TeacherCourse < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :user
  belongs_to :course
  belongs_to :degree
  attr_accessible :degree_id, :course_id, :user_id
end
