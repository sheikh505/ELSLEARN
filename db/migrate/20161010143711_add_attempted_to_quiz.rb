class AddAttemptedToQuiz < ActiveRecord::Migration
  def change
    add_column :quizzes, :attempted, :boolean, :default => false
  end
end
