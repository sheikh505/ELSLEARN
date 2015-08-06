class Book < ActiveRecord::Base
  belongs_to :degree
  belongs_to :course

  attr_accessible :description, :name,:avatar, :price, :degree_id, :course_id, :author

  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
end
