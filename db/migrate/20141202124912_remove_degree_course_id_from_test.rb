class RemoveDegreeCourseIdFromTest < ActiveRecord::Migration
  def up
    remove_column :tests, :degree_course_id
  end

  def down
    add_column :tests, :degree_course_id, :integer
  end
end
