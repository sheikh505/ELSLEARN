class AddColumnToQuestions < ActiveRecord::Migration
  def change
    add_column :questions, :varient, :string
  end
end
