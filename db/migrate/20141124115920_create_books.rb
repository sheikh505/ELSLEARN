class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :name
      t.string :price
      t.string :description
      t.belongs_to :degree_course_assignment

      t.timestamps
    end
  end
end
