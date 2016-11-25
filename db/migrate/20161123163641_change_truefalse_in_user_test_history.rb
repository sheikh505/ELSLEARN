class ChangeTruefalseInUserTestHistory < ActiveRecord::Migration
  def up
    change_column :user_test_histories, :truefalse, :string
  end

  def down
  end
end
