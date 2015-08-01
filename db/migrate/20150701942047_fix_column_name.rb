class FixColumnName < ActiveRecord::Migration
  def self.up
    change_column :membership_plans, :paper,  :string
  end

  def self.down
    # rename back if you need or do something else or do nothing
  end
end
