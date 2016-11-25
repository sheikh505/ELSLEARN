class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.integer :user_test_history_id
      t.integer :question_id
      t.string :answer_detail
      t.integer :marks
      t.string :remarks

      t.timestamps
    end
  end
end
