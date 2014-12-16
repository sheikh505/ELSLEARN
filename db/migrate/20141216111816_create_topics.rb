class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics do |t|
      t.string :name
      t.belongs_to :degree_course_assignment
      t.timestamps
    end
  end
end
