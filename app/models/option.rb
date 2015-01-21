class Option < ActiveRecord::Base
  belongs_to :question
  attr_accessible :statement, :question_id,:is_answer, :flag
  attr_accessible :avatar
  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x100>" },
                    :default_url => "/images/:style/missing.png",
                    :default_url => "/images/:style/missing.png",
                    :storage => :s3,
                    :url => 's3_domain_url',
                    :s3_host_alias => 'elslearning.s3-website-us-east-1.amazonaws.com',
                    :s3_credentials => File.join(Rails.root, 'config', 's3.yml'),
                    :path => "/files/:style/:id_:filename"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
end
