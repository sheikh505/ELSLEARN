class AddTotalQuestionsToUserTestHistory < ActiveRecord::Migration
  def change
    add_column :user_test_histories, :total_questions, :integer
  end
end
