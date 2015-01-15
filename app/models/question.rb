class Question < ActiveRecord::Base
  has_many :options, dependent: :destroy
  belongs_to :topic
  has_one :past_paper_history

  has_many :board_question_assignments
  has_many :board_degree_assignments,through: :board_question_assignments


  attr_accessible :answer, :statement, :description, :test_id, :instruction, :source, :author, :difficulty, :board, :topic_id, :question_type, :deleted
end
