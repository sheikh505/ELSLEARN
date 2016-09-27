class Ckeditor::AttachmentFile < Ckeditor::Asset
  has_attached_file :data, :styles => { :medium => "300x300>", :thumb => "100x100>" },
                    :default_url => "/images/:style/missing.png",
                    :storage => :s3,
                    :url => 's3_domain_url',
                    :s3_host_alias => 'elslearning.s3-website-us-east-1.amazonaws.com',
                    :s3_credentials => File.join(Rails.root, 'config', 's3.yml'),
                    :path => "/files/:style/:id_:filename"
  

  def url_thumb
    @url_thumb ||= Ckeditor::Utils.filethumb(filename)
  end
end
