class CreateWorkflowPaths < ActiveRecord::Migration
  def change
    create_table :workflow_paths do |t|
      t.integer :course_id
      t.integer :degree_id
      t.boolean :is_complete,default: true

      t.timestamps
    end
  end
end
