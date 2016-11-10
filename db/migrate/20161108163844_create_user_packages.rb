class CreateUserPackages < ActiveRecord::Migration
  def change
    create_table :user_packages do |t|
      t.integer :package_id
      t.datetime :validity
      t.integer :credit_left
      t.integer :user_id

      t.timestamps
    end
  end
end
