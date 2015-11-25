class Users::RegistrationsController < Devise::RegistrationsController
  layout "login_layout"
# before_filter :configure_sign_up_params, only: [:create]
# before_filter :configure_account_update_params, only: [:update]

# GET /resource/sign_up
# def new
#   super
# end
  def update_user
    respond_to do |format|
      @user = User.find(params[:id])
      if @user.nil?
        @flag = false
      else
        if @user.update_attributes(params[:user])
          ###### save degrees #######
            @user.update_attribute(:degrees,params[:degrees].join(",")) unless params[:degrees].blank?
          ##### save courses ########
            @user.update_attribute(:courses,params[:courses].join(",")) unless params[:courses].blank?
          @flag = true
        else
          @flag = false
        end
      end
      format.js
    end
  end
# POST /resource
  def create
    respond_to do |format|
      build_resource(sign_up_params)

      resource.save
      yield resource if block_given?
      if resource.persisted?
        if resource.active_for_authentication?
          set_flash_message :notice, :signed_up if is_flashing_format?
          sign_up(resource_name, resource)
          ######## set role for user ########
          unless params[:role].blank?
            Assignment.create(user_id: resource.id,role_id: params[:role])
            if resource.roles.first.name.downcase == 'teacher'
              str = "#{resource.email.split("@").first}_#{(0...5).map { (65 + rand(26)).chr }.join}"
              resource.update_attribute(:teacher_token,str)
            end
          end
          ##### role ends ###################
          @flag = true
          # respond_with resource, location: after_sign_up_path_for(resource)
        else
          set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
          expire_data_after_sign_in!
          @flag = false
          # respond_with resource, location: after_inactive_sign_up_path_for(resource)
        end
      else
        clean_up_passwords resource
        set_minimum_password_length
        @flag = false
        # respond_with resource
      end
      @user = resource if @flag == true
      format.js
    end
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # You can put the params you want to permit in the empty array.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.for(:sign_up) << :attribute
  # end

  # You can put the params you want to permit in the empty array.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.for(:account_update) << :attribute
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
