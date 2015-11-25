class TeacherRequest < ActiveRecord::Base
  attr_accessible :status, :student_email, :student_id, :student_name, :teacher_code,:teacher_token

  belongs_to :user,:class_name => "Student"
end
