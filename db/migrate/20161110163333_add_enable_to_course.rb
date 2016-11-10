class AddEnableToCourse < ActiveRecord::Migration
  def change
    add_column :courses, :enable, :boolean, default: false
  end
end
