class Topic < ActiveRecord::Base
  has_many :questions
  belongs_to :course
  attr_accessible :name

  validates :name, :uniqueness => true
end
