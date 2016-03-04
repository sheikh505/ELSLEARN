class AddDifficutyStrColumnToQuestionHistories < ActiveRecord::Migration
  def change
    add_column :question_histories, :difficulty_str, :string
  end
end
