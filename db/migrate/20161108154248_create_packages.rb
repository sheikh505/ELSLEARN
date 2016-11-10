class CreatePackages < ActiveRecord::Migration
  def change
    create_table :packages do |t|
      t.string :name
      t.integer :price
      t.integer :degree_id
      t.boolean :mcq
      t.boolean :fill
      t.boolean :true_false
      t.boolean :descriptive
      t.boolean :past_paper
      t.boolean :instant_result
      t.boolean :teacher_review
      t.boolean :video_review
      t.timestamps
    end
  end
end