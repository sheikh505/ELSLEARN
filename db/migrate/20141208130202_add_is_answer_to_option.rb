class AddIsAnswerToOption < ActiveRecord::Migration
  def change
    add_column :options, :is_answer, :int
  end
end
