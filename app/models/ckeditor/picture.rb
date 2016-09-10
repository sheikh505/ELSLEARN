class Ckeditor::Picture < Ckeditor::Asset
  # has_attached_file :data,
  #                   url: '/ckeditor_assets/pictures/:id/:style_:basename.:extension',
  #                   path: ':rails_root/public/ckeditor_assets/pictures/:id/:style_:basename.:extension',
  #                   styles: { content: '800>', thumb: '118x100#' }

  has_attached_file :data, :styles => { :medium => "300x300>", :thumb => "100x100>" },
                    :default_url => "/images/:style/missing.png",
                    :storage => :s3,
                    :url => 's3_domain_url',
                    :s3_host_alias => 'elslearning.s3-website-us-east-1.amazonaws.com',
                    :s3_credentials => File.join(Rails.root, 'config', 's3.yml'),
                    :path => "/files/:style/:id_:filename"

  def url_content
    url(:original)
  end
end
