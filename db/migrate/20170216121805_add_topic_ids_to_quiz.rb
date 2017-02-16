class AddTopicIdsToQuiz < ActiveRecord::Migration
  def change
    add_column :quizzes, :topic_ids, :string
  end
end
