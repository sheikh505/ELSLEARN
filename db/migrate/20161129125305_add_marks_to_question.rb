class AddMarksToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :marks, :integer, default: 1
  end
end
