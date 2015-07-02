class FixColumnName < ActiveRecord::Migration
  def self.up
    change_column :question_histories, :board_id,  :string
    change_column :question_histories, :degree_id,  :string
    rename_column :question_histories, :board_id, :board_ids
    rename_column :question_histories, :degree_id, :degree_ids
  end

  def self.down
    # rename back if you need or do something else or do nothing
  end
end
