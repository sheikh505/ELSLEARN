class ChangeDataTypeForMembershipPlan < ActiveRecord::Migration
  change_table :membership_plans do |t|
    t.change :result_type, :text
  end
end
