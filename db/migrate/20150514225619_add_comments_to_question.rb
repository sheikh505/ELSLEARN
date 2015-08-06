class AddCommentsToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :comments, :string
  end
end
