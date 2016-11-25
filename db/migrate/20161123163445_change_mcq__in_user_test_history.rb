class ChangeMcqInUserTestHistory < ActiveRecord::Migration
  def up
    change_column :user_test_histories, :mcq, :string
  end

  def down
  end
end
