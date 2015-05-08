class AddCourseIdToTeacherCourses < ActiveRecord::Migration
  def change
    add_column :teacher_courses, :course_id, :integer
  end
end
