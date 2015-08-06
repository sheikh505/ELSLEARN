class CreateQuestionHistories < ActiveRecord::Migration
  def change
    create_table :question_histories do |t|
      t.integer :user_id
      t.integer :question_id
      t.integer :board_id
      t.integer :degree_id
      t.integer :difficulty
      t.integer :topic_id
      t.boolean :is_approved

      t.timestamps
    end
  end
end
