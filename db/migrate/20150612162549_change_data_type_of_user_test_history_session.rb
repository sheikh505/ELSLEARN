class ChangeDataTypeOfUserTestHistorySession < ActiveRecord::Migration
  def up
    change_column :user_test_histories do |t|
      t.change :session, :string
    end
  end

  def down
    change_column :user_test_histories do |t|
      t.change :session, :integer
    end
  end
end
