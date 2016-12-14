class ApplicationController < ActionController::Base
  include TopicsHelper
  rescue_from CanCan::AccessDenied do |exception|
    #render :file => "#{Rails.root}/public/403.html", :status => 403, :layout => false
    ## to avoid deprecation warnings with Rails 3.2.x (and incidentally using Ruby 1.9.3 hash syntax)
    ## this render call should be:
    render :file=> "#{Rails.root}/public/403", :formats=> [:html], :status=> 403, :layout=> false
  end
  def get_parent_topic_name(topic_id)

    topic_id.nil? ? "":Topic.find(topic_id).name

  end

  def after_sign_in_path_for(resource)
    if resource.is_student?
      root_path
    else
      '/admin_panel'
    end
  end
end
