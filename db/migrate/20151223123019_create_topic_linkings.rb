class CreateTopicLinkings < ActiveRecord::Migration
  def change
    create_table :topic_linkings do |t|
      t.integer :topic_1
      t.integer :topic_2
      t.integer :topic_3
      t.integer :topic_4
      t.integer :course_linking_id

      t.timestamps
    end
  end
end
