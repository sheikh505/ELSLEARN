class RemoveDegreeCourseAssigbmentFromTest < ActiveRecord::Migration
  def up
    remove_column :tests, :degree_course_assignment_id
  end

  def down
    add_column :tests, :degree_course_assignment_id, :integer
  end
end
