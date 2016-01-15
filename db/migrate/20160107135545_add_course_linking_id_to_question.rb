class AddCourseLinkingIdToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :course_linking_id, :integer
  end
end
