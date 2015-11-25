class AddInstituteToUser < ActiveRecord::Migration
  def change
    add_column :users, :institute, :string
    add_column :users, :degree_id, :integer
  end
end
