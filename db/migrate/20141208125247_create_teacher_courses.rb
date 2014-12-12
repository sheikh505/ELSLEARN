class CreateTeacherCourses < ActiveRecord::Migration
  def change
    create_table :teacher_courses do |t|
      t.belongs_to :user
      t.belongs_to :degree_course_assignment
      t.timestamps
    end
  end
end
