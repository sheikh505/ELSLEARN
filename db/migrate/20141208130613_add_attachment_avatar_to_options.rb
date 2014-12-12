class AddAttachmentAvatarToOptions < ActiveRecord::Migration
  def self.up
    change_table :options do |t|
      t.attachment :avatar
    end
  end

  def self.down
    remove_attachment :options, :avatar
  end
end
