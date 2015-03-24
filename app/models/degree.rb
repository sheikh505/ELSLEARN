class Degree < ActiveRecord::Base


  has_many :board_degree_assignments, :dependent => :destroy
  has_many :boards, through: :board_degree_assignments
  has_many :books
  attr_accessible :name
  validates :name, :uniqueness => true
end
