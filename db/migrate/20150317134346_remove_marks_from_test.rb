class RemoveMarksFromTest < ActiveRecord::Migration
  def up
    remove_column :tests, :marks
  end

  def down
    add_column :tests, :marks, :integer
  end
end
