class BoardDegreeAssignment < ActiveRecord::Base
  belongs_to :degree
  belongs_to :board
  has_many :degree_course_assignments, :dependent => :destroy
  has_many :courses , through: :degree_course_assignments

  has_many :board_question_assignments, :dependent => :destroy
  has_many :questions,through: :board_question_assignments


  attr_accessible :degree_id, :board_id
  validates :degree_id, :uniqueness => {:scope => :board_id}
  # attr_accessible :title, :body





end
