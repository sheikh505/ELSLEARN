class CreateTeacherRequests < ActiveRecord::Migration
  def change
    create_table :teacher_requests do |t|
      t.integer :teacher_code
      t.integer :student_id
      t.string :student_name
      t.string :student_email
      t.string :status

      t.timestamps
    end
  end
end
