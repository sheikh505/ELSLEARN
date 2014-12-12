class Test < ActiveRecord::Base
  belongs_to :degree_course_assignment
  has_many :questions

  # attr_accessible :title, :body
  attr_accessible :degree_course_id, :marks, :name
end
