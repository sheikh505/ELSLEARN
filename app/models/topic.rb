class Topic < ActiveRecord::Base
  has_many :questions
  has_many :question_histories
  belongs_to :course
  attr_accessible :name,:parent_topic_id

end
