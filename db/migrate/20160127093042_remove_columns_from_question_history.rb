class RemoveColumnsFromQuestionHistory < ActiveRecord::Migration
  def up
    remove_column :question_histories, :board_id
    remove_column :question_histories, :degree_id
  end

  def down
    add_column :question_histories, :degree_id, :integer
    add_column :question_histories, :board_id, :integer
  end
end
