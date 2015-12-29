class CourseLinking < ActiveRecord::Base
  attr_accessible :course_1, :course_2, :course_3, :course_4
  has_many :topic_linking,dependent: :destroy

  def self.search_on_course_column course_id
    if course_id.nil?
      return nil
    else
      arr = self.where("course_1 = ? OR course_2 = ? OR course_3 = ? OR course_4 = ?",course_id,course_id,course_id,course_id)
      return arr.blank? ? nil : arr.first
    end
  end
end
