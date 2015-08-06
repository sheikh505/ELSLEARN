class AddDetailsToUserTestHistory < ActiveRecord::Migration
  def change
    add_column :user_test_histories, :board_id, :integer
    add_column :user_test_histories, :degree_id, :integer
    add_column :user_test_histories, :pastpaperflag, :integer
    add_column :user_test_histories, :mcq, :integer
    add_column :user_test_histories, :fill, :integer
    add_column :user_test_histories, :truefalse, :integer
    add_column :user_test_histories, :descriptive, :integer
    add_column :user_test_histories, :year, :integer
    add_column :user_test_histories, :session, :integer
  end
end
