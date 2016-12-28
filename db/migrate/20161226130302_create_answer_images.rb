class CreateAnswerImages < ActiveRecord::Migration
  def change
    create_table :answer_images do |t|
      t.integer :answer_id
      t.attachment :image

      t.timestamps
    end
  end
end
