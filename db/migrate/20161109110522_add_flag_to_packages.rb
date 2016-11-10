class AddFlagToPackages < ActiveRecord::Migration
  def change
    add_column :packages, :flag, :integer
  end
end
