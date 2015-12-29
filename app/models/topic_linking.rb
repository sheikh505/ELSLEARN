class TopicLinking < ActiveRecord::Base
  belongs_to :course_linking
  attr_accessible :course_linking_id, :topic_1, :topic_2, :topic_3, :topic_4
end
