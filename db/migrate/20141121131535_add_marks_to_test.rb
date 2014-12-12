class AddMarksToTest < ActiveRecord::Migration
  def change
    add_column :tests, :marks, :string
  end
end
