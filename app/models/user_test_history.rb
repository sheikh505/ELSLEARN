class UserTestHistory < ActiveRecord::Base
  belongs_to :user
  belongs_to :course



  attr_accessible :code, :board_id, :degree_id, :course_id, :pastpaperflag, :video_review, :teacher_id, :student_feedback, :reviewed,
                  :mcq, :is_live, :quiz_name, :fill, :truefalse, :descriptive, :year, :session, :score, :total, :user_id, :topic_ids
end
