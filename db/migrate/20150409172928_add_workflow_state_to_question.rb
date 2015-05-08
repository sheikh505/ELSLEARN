class AddWorkflowStateToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :workflow_state, :string
  end
end
