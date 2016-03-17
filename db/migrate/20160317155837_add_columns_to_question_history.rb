class AddColumnsToQuestionHistory < ActiveRecord::Migration
  def change
    add_column :question_histories, :board_ids, :string
    add_column :question_histories, :degree_ids, :string
  end
end
