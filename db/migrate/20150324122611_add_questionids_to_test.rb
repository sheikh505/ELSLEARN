class AddQuestionidsToTest < ActiveRecord::Migration
  def change
    add_column :tests, :questionids, :string
  end
end
