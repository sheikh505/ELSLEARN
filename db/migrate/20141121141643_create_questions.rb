class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :statement
      t.string :answer
      t.boolean :deleted
      t.belongs_to :test
      t.belongs_to :topic
      t.timestamps
    end
  end
end
