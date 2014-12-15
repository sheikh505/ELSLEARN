class CreatePastPaperHistories < ActiveRecord::Migration
  def change
    create_table :past_paper_histories do |t|
      t.integer :flag
      t.string :session
      t.string :year
      t.string :paper
      t.string :ques_no
      t.belongs_to :question

      t.timestamps
    end
  end
end
