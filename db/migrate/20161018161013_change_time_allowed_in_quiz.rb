class ChangeTimeAllowedInQuiz < ActiveRecord::Migration
  def up
    change_table :quizzes do |t|
      t.change :time_allowed, :float
    end
  end

  def down
  end
end
