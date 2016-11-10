class AddEnableToBoard < ActiveRecord::Migration
  def change
    add_column :boards, :enable, :boolean, default: false
  end
end
