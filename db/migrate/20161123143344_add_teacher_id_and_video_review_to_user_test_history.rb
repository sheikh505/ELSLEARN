class AddTeacherIdAndVideoReviewToUserTestHistory < ActiveRecord::Migration
  def change
    add_column :user_test_histories, :video_review, :boolean
    add_column :user_test_histories, :teacher_id, :integer
  end
end
