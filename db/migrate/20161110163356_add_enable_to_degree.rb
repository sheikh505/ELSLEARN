class AddEnableToDegree < ActiveRecord::Migration
  def change
    add_column :degrees, :enable, :boolean, default: false
  end
end
