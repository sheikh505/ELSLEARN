class Topic < ActiveRecord::Base
  has_many :questions
  has_many :question_histories
  belongs_to :course
  attr_accessible :name,:parent_topic_id

  # belongs_to :parenttopic, class_name: "Topic"

  # has_many :parenttopics, class_name: "Topic",
  #          foreign_key: "manager_id"
  #
  # belongs_to :manager, class_name: "Employee"

  #
  # has_one :parenttopic, class_name: "Topic",
  #     foreign_key: 'topic_id'


end

#
#
# class Employee < ActiveRecord::Base
#   has_many :subordinates, class_name: "Employee",
#            foreign_key: "manager_id"
#
#   belongs_to :manager, class_name: "Employee"
# end