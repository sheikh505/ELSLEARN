class AddDegreesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :degrees, :string
    add_column :users, :courses, :string
  end
end
