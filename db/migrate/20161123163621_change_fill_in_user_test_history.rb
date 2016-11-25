class ChangeFillInUserTestHistory < ActiveRecord::Migration
  def up
    change_column :user_test_histories, :fill, :string
  end

  def down
  end
end
