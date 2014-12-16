class Topic < ActiveRecord::Base
  has_many :questions
  belongs_to :degree_course_assignment
  attr_accessible :name
end
