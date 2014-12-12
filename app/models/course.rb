class Course < ActiveRecord::Base
  has_many :degree_course_assignments, :dependent => :destroy
  has_many :degrees, through: :degree_course_assignments
  attr_accessible :name
end
