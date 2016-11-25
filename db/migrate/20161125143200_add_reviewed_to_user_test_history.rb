class AddReviewedToUserTestHistory < ActiveRecord::Migration
  def change
    add_column :user_test_histories, :reviewed, :boolean, default: false
  end
end
