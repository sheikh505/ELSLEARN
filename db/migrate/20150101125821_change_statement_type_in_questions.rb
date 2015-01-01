class ChangeStatementTypeInQuestions < ActiveRecord::Migration
  def up
    change_column :questions, :statement, :text, :limit => 4294967295
  end

  def down
    change_column :questions, :statement, :string
  end
end
