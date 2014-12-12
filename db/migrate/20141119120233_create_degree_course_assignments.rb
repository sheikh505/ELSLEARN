class CreateDegreeCourseAssignments < ActiveRecord::Migration
  def change
    create_table :degree_course_assignments do |t|
      t.belongs_to :degree
      t.belongs_to :course

      t.timestamps
    end
  end
end
