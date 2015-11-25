class AddFreePlanFlagToUser < ActiveRecord::Migration
  def change
    add_column :users, :free_plan_flag, :boolean
  end
end
