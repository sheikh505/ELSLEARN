class QuestionHistory < ActiveRecord::Base
  belongs_to :question, :board, :degree, :topic, :user
  attr_accessible :board_id, :degree_id, :difficulty, :is_approved, :question_id, :topic_id, :user_id
end
