class AddNameToUserTestHistory < ActiveRecord::Migration
  def change
    add_column :user_test_histories, :quiz_name, :string
  end
end
