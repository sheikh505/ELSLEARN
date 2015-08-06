class UserTestHistory < ActiveRecord::Base
  belongs_to :user
  belongs_to :course
  attr_accessible :code, :board_id, :degree_id, :course_id, :pastpaperflag,
                  :mcq, :fill, :truefalse, :descriptive, :year, :session, :score, :total, :user_id
end
