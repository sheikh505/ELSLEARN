class AddAttachmentImageToAnswers < ActiveRecord::Migration
  def self.up
    change_table :answers do |t|
      t.attachment :image
    end
  end

  def self.down
    drop_attached_file :answers, :image
  end
end
