class Question < ActiveRecord::Base
  has_many :options
  belongs_to :test
  attr_accessible :answer, :statement, :description, :test_id, :instruction, :source, :author, :difficulty
end
