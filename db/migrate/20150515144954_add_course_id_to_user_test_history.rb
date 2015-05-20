class AddCourseIdToUserTestHistory < ActiveRecord::Migration
  def change
    add_column :user_test_histories, :course_id, :integer
  end
end
