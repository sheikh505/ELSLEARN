class AddCourseIdToUserPackage < ActiveRecord::Migration
  def change
    add_column :user_packages, :course_id, :integer
  end
end
