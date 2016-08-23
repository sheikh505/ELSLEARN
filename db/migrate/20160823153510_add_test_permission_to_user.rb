class AddTestPermissionToUser < ActiveRecord::Migration
  def change
    add_column :users, :test_permission_ids, :string
  end
end
