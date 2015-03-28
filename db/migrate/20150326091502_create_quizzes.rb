class CreateQuizzes < ActiveRecord::Migration
  def change
    create_table :quizzes do |t|
      t.string :name
      t.string :test_code
      t.string :question_ids
      t.integer :user_id

      t.timestamps
    end
  end
end
