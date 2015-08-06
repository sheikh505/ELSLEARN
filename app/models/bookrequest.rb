class Bookrequest < ActiveRecord::Base
  belongs_to :user
  attr_accessible :author, :edition, :name, :reason, :status
end
