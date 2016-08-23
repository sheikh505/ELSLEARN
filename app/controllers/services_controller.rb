class ServicesController < ApplicationController
  respond_to :json
  skip_before_filter :authenticate_user!
  before_filter :check_session, :except => [:sign_in]

  def sign_in
    user = User.find_by_email(params[:user][:email])
    if user.present? && user.valid_password?(params[:user][:password])
        user.update_attributes(:device_token => params[:user][:token])
        user.role = user.roles.first.name.downcase
        # data = {:auth_token => user.auth_token}
        render :json => {:success => "true", :user => user, :message => "User signed In"}
    else
      render :json => {:success => "false", :message => "Invalid Email Or Password."}
    end
  end

  private
  def check_session
    if params[:auth_token].present?
      @user = User.find_by_auth_token(params[:auth_token])
      render :json => {:success => "false", :errors => "authentication failed"} unless @user.present?
    else
      render :json => {:success => "false", :errors => "authentication failed"}
    end
  end

end
