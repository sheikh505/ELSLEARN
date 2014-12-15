class Image < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :alt, :hint, :file

  has_attached_file :file, :styles => { :medium => "300x300>", :thumb => "100x100>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :file, :content_type => /\Aimage\/.*\Z/
end
