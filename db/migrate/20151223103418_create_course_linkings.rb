class CreateCourseLinkings < ActiveRecord::Migration
  def change
    create_table :course_linkings do |t|
      t.integer :course_1
      t.integer :course_2
      t.integer :course_3
      t.integer :course_4

      t.timestamps
    end
  end
end
