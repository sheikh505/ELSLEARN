class UserTestHistory < ActiveRecord::Base
  belongs_to :user
  belongs_to :course



  attr_accessible :code, :board_id, :degree_id, :course_id, :pastpaperflag,
                  :mcq, :is_live, :quiz_name, :fill, :truefalse, :descriptive, :year, :session, :score, :total, :user_id, :topic_ids
end
