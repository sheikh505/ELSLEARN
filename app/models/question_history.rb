class QuestionHistory < ActiveRecord::Base
  belongs_to :question
  belongs_to :board
  belongs_to :degree
  belongs_to :topic
  belongs_to :user
  attr_accessible :board_id, :degree_id, :difficulty, :is_approved, :question_id, :topic_id, :user_id
end
