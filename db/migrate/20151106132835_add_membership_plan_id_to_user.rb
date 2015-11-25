class AddMembershipPlanIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :membership_plan_id, :integer
  end
end
