class AddDegreeIdToTeacherCourses < ActiveRecord::Migration
  def change
    add_column :teacher_courses, :degree_id, :integer
  end
end
