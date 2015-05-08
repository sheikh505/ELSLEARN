class AddCourseToTest < ActiveRecord::Migration
  def change
    add_column :tests, :course_id, :integer
  end
end
