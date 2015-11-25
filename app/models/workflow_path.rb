class WorkflowPath < ActiveRecord::Base
  attr_accessible :course_id, :degree_id, :is_complete
  belongs_to :degree
  belongs_to :course


  def self.check_state(degree_id,course_id)
    arr = self.where(degree_id: degree_id,course_id: course_id)
    arr.blank? ? true : arr.first.is_complete
  end
end
