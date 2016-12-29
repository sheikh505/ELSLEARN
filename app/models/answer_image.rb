class AnswerImage < ActiveRecord::Base
  attr_accessible :answer_id, :image

  belongs_to :answer

  has_attached_file :image, :styles => { :medium => "300x300>", :thumb => "100x100>" },
                    :path => "/files/:style/:id_:filename",
                    :default_url => "/images/:style/missing.png",
                    :storage => :s3,
                    :url => 's3_domain_url',
                    :s3_host_alias => 'elslearning.s3-website-us-east-1.amazonaws.com',
                    :s3_credentials => File.join(Rails.root, 'config', 's3.yml')

end
