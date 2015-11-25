class AddStudentAmountToUser < ActiveRecord::Migration
  def change
    add_column :users, :student_amount, :string
  end
end
