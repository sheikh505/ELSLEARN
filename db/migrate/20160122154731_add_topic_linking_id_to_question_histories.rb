class AddTopicLinkingIdToQuestionHistories < ActiveRecord::Migration
  def change
    add_column :question_histories, :topic_linking_id, :integer
  end
end
