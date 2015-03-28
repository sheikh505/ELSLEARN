class UserTestHistory < ActiveRecord::Base
  belongs_to :user
  attr_accessible :code, :course, :score, :total,:user_id
end
