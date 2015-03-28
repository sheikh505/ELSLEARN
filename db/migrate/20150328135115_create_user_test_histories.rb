class CreateUserTestHistories < ActiveRecord::Migration
  def change
    create_table :user_test_histories do |t|
      t.string :course
      t.integer :score
      t.integer :total
      t.string :code
      t.belongs_to :user

      t.timestamps
    end
  end
end
