class AddTimeAllowedToQuiz < ActiveRecord::Migration
  def change
    add_column :quizzes, :time_allowed, :integer
  end
end
