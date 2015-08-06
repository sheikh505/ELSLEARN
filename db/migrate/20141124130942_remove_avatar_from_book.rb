class RemoveAvatarFromBook < ActiveRecord::Migration
  def up
    remove_column :books, :avatar
  end

  def down
    add_column :books, :avatar, :string
  end
end
