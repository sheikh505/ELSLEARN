class CreateBoardQuestionAssignments < ActiveRecord::Migration
  def change
    create_table :board_question_assignments do |t|
      t.belongs_to :question
      t.belongs_to :board_degree_assignment
      t.timestamps
    end
  end
end
