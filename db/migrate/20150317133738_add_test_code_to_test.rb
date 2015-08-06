class AddTestCodeToTest < ActiveRecord::Migration
  def change
    add_column :tests, :test_code, :string
  end
end
