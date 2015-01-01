class ChangeStatementTypeInQuestions < ActiveRecord::Migration
  def up
    change_column :questions, :statement, :text
  end

  def down
    change_column :questions, :statement, :string
  end
end
