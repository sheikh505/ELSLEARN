class RemoveTopicLinkingIdFromQuestionHistories < ActiveRecord::Migration
  def up
    remove_column :question_histories, :topic_linking_id
  end

  def down
    add_column :question_histories, :topic_linking_id, :integer
  end
end
