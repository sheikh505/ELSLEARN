class AddInstructionToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :instruction, :string
  end
end
