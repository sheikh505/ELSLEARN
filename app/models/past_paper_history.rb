  class PastPaperHistory < ActiveRecord::Base
  belongs_to :question
  attr_accessible :flag, :paper, :ques_no, :session, :year, :question_id, :course_id
end
