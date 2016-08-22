class ChangeFormatInMyTable < ActiveRecord::Migration
  def change
    change_column :user_test_histories, :topic_ids, :text
  end
end
