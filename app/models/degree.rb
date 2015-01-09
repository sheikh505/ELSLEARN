class Degree < ActiveRecord::Base
  has_many :degree_course_assignments, :dependent => :destroy
  has_many :courses, through: :degree_course_assignments

  has_many :board_degree_assignments, :dependent => :destroy
  has_many :boards, through: :board_degree_assignments

  attr_accessible :name
  validates :name, :uniqueness => true
end
