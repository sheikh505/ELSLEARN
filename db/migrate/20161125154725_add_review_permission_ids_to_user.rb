class AddReviewPermissionIdsToUser < ActiveRecord::Migration
  def change
    add_column :users, :review_permission_ids, :string, default: ""
  end
end
