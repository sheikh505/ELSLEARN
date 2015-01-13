class BoardQuestionAssignment < ActiveRecord::Base
  belongs_to :board_degree_assignment
  belongs_to :question
  # attr_accessible :title, :body
  attr_accessible :question_id, :board_degree_assignment_id
end
