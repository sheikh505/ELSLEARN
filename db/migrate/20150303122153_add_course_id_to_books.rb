class AddCourseIdToBooks < ActiveRecord::Migration
  def change
    add_column :books, :course_id, :int
    add_column :books, :degree_id, :int
  end
end
