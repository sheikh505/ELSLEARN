class AddAttachmentVideoToAnswers < ActiveRecord::Migration
  def self.up
    change_table :answers do |t|
      t.attachment :video
    end
  end

  def self.down
    drop_attached_file :answers, :video
  end
end
