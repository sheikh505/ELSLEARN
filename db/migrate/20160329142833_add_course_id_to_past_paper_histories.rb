class AddCourseIdToPastPaperHistories < ActiveRecord::Migration
  def change
    add_column :past_paper_histories, :course_id, :string
  end
end
