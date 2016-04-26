class AddTopicIdsToUserTestHistories < ActiveRecord::Migration
  def change
    add_column :user_test_histories, :topic_ids, :string
  end
end
