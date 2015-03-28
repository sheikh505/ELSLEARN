class AddCourseToQuiz < ActiveRecord::Migration
  def change
    add_column :quizzes, :course_id, :integer
  end
end
