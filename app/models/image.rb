class Image < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :alt, :hint, :file

  has_attached_file :file, :styles => { :medium => "300x300>", :thumb => "100x100>" },
                    :default_url => "/images/:style/missing.png",
                    :storage => :s3,
                    :url => 's3_domain_url',
                    :s3_host_alias => 'elslearning.s3-website-us-east-1.amazonaws.com',
                    :s3_credentials => File.join(Rails.root, 'config', 's3.yml'),
                    :path => "/files/:style/:id_:filename"

  validates_attachment_content_type :file, :content_type => /\Aimage\/.*\Z/
end
