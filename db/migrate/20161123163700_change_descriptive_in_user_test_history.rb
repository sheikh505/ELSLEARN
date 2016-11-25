class ChangeDescriptiveInUserTestHistory < ActiveRecord::Migration
  def up
    change_column :user_test_histories, :descriptive, :string
  end

  def down
  end
end
