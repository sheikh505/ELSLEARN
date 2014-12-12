class AddDegreeCourseIdToTest < ActiveRecord::Migration
  def change
    add_column :tests, :degree_course_id, :integer
    add_index :tests, :degree_course_id
  end
end
