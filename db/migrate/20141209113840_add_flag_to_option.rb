class AddFlagToOption < ActiveRecord::Migration
  def change
    add_column :options, :flag, :int
  end
end
