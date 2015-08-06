class CreateBookrequests < ActiveRecord::Migration
  def change
    create_table :bookrequests do |t|
      t.string :name
      t.string :author
      t.string :edition
      t.string :status
      t.text :reason
      t.belongs_to :user

      t.timestamps
    end
  end
end
