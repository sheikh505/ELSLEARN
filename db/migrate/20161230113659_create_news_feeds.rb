class CreateNewsFeeds < ActiveRecord::Migration
  def change
    create_table :news_feeds do |t|
      t.text :title
      t.integer :id

      t.timestamps
    end
  end
end
