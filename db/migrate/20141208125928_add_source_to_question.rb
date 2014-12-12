class AddSourceToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :source, :string
  end
end
