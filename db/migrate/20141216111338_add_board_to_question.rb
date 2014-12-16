class AddBoardToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :board, :string
  end
end
