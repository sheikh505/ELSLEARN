class AddTopicIdsToQuestionHistories < ActiveRecord::Migration
  def change
    add_column :question_histories, :topic_ids, :string
  end
end
