class AddQuestionIdToTest < ActiveRecord::Migration
  def change
    add_column :tests, :question_ids, :string
  end
end
