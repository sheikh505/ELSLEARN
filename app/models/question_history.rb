class QuestionHistory < ActiveRecord::Base
  belongs_to :question
  belongs_to :board
  belongs_to :degree
  belongs_to :topic
  belongs_to :user
  attr_accessible :board_ids, :degree_ids, :difficulty, :is_approved, :question_id, :topic_id, :user_id, :difficulty_str
end
