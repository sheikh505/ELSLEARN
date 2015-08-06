class CreateTests < ActiveRecord::Migration
  def change
    create_table :tests do |t|
      t.belongs_to :degree_course_assignment
      t.timestamps
    end
  end
end
