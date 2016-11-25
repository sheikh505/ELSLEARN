class AddStudentFeedbackToUserTestHistory < ActiveRecord::Migration
  def change
    add_column :user_test_histories, :student_feedback, :string
  end
end
