class CreateUserAddresses < ActiveRecord::Migration
  def change
    create_table :user_addresses do |t|
      t.string :address
      t.string :state
      t.string :city
      t.string :zipcode
      t.string :coutry
      t.belongs_to :user

      t.timestamps
    end
  end
end
