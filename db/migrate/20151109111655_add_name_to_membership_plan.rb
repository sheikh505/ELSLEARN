class AddNameToMembershipPlan < ActiveRecord::Migration
  def change
    add_column :membership_plans, :name, :string
  end
end
