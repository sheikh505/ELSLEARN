class RemoveDegreeCourseAssignmentIdFromTeacherCourses < ActiveRecord::Migration
  def up
    remove_column :teacher_courses, :degree_course_assignment_id
  end

  def down
    add_column :teacher_courses, :degree_course_assignment_id, :string
  end
end
