class CreateBoardDegreeAssignments < ActiveRecord::Migration
  def change
    create_table :board_degree_assignments do |t|
      t.belongs_to :degree
      t.belongs_to :board
      t.timestamps
    end
  end
end
