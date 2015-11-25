class AddTeacherTokenToTeacherRequest < ActiveRecord::Migration
  def change
    add_column :teacher_requests, :teacher_token, :string
  end
end
