class AddFieldsToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :topic_ids, :string
    add_column :questions, :difficulty_ids, :string
    add_column :questions, :degree_ids, :string
  end
end
