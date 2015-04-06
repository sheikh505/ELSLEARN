class UserTestHistory < ActiveRecord::Base
  belongs_to :user
  attr_accessible :code, :board_id, :degree_id, :course, :pastpaperflag,
                  :mcq, :fill, :truefalse, :descriptive, :year, :session, :score, :total, :user_id
end
