class CreateQuestionQuota < ActiveRecord::Migration
  def change
    create_table :question_quota do |t|
      t.integer :question_type
      t.integer :quota

      t.timestamps
    end
  end
end
