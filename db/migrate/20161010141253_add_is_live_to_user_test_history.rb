class AddIsLiveToUserTestHistory < ActiveRecord::Migration
  def change
    add_column :user_test_histories, :is_live, :boolean, :default => false
  end
end
