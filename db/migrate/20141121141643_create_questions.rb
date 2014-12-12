class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :statement
      t.string :answer
      t.belongs_to :test
      t.timestamps
    end
  end
end
