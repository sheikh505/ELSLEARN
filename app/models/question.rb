class Question < ActiveRecord::Base
  has_many :options
  belongs_to :test
  belongs_to :topic
  has_one :past_paper_history
  attr_accessible :answer, :statement, :description, :test_id, :instruction, :source, :author, :difficulty, :board, :topic_id, :question_type
end
