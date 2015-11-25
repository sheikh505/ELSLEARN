class AddTeacherTokenToUser < ActiveRecord::Migration
  def change
    add_column :users, :teacher_token, :string
  end
end
