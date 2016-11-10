class AddPlanAndNameToUserPackage < ActiveRecord::Migration
  def change
    add_column :user_packages, :plan, :string
    add_column :user_packages, :name, :string
  end
end
