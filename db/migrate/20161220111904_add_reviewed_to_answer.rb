class AddReviewedToAnswer < ActiveRecord::Migration
  def change
    add_column :answers, :reviewed, :boolean, default: false
  end
end
