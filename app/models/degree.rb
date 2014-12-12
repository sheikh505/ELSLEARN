class Degree < ActiveRecord::Base
  has_many :degree_course_assignments, :dependent => :destroy
  has_many :courses, through: :degree_course_assignments
  attr_accessible :name
end
