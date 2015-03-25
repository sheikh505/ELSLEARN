class RemoveDegreeCourseAssignmentIdFromBooks < ActiveRecord::Migration
  def up
    remove_column :books, :degree_course_assignment_id
  end

  def down
    add_column :books, :degree_course_assignment_id, :int
  end
end
