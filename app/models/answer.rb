class Answer < ActiveRecord::Base
  attr_accessible :answer_detail, :marks, :question_id, :remarks, :user_test_history_id, :image, :video, :reviewed

  has_many :answer_images
  belongs_to :user_test_history

  has_attached_file :image, :styles => { :medium => "300x300>", :thumb => "100x100>" },
                    :path => "/files/:style/:id_:filename",
                    :default_url => "/images/:style/missing.png",
                    :storage => :s3,
                    :url => 's3_domain_url',
                    :s3_host_alias => 'elslearning.s3-website-us-east-1.amazonaws.com',
                    :s3_credentials => File.join(Rails.root, 'config', 's3.yml')

  has_attached_file :video,
                    :storage => :s3,
                    :url => 's3_domain_url',
                    :s3_host_alias => 'elslearning.s3-website-us-east-1.amazonaws.com',
                    :s3_credentials => File.join(Rails.root, 'config', 's3.yml'),
                    :path => "/files/original/:id_:filename",
                    :use_timestamp => false
end
