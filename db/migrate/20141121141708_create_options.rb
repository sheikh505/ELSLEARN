class CreateOptions < ActiveRecord::Migration
  def change
    create_table :options do |t|
      t.string :statement
      t.belongs_to :question

      t.timestamps
    end
  end
end
