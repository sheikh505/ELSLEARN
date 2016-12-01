class Users::RegistrationsController < Devise::RegistrationsController
  layout "login_layout"
# before_filter :configure_sign_up_params, only: [:create]
# before_filter :configure_account_update_params, only: [:update]

# GET /resource/sign_up
# def new
#   super
# end
#   def save_form_2
#     respond_to do |format|
#       @user = User.find(params[:id])
#       if @user.nil?
#         @flag = false
#       else
#         if @user.update_attributes(params[:user])
#           ###### save degrees #######
#             @user.update_attribute(:degrees, params[:degrees].join(",")) unless params[:degrees].blank?
#           ##### save courses ########
#             # puts "=======================>" + params[:courses].join(',').inspect
#             # die
#             unless params[:courses].blank?
#               @user[:courses] = params[:courses].join(',')
#               @user.save
#             end
#           @flag = true
#         else
#           @flag = false
#         end
#       end
#       format.js
#     end
#   end

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
            Assignment.create!(user_id: resource.id,role_id: params[:role])
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

  def save_form_1
    session[:user] = Hash.new
    session[:user][:email] = params[:user][:email]
    session[:user][:name] = params[:user][:name]
    session[:user][:password] = params[:user][:password]
    session[:user][:password_confirmation] = params[:user][:password_confirmation]
    session[:role] = params[:role]
    @role = Role.find(params[:role])
    if params[:role] != "5"
      degrees = Degree.all
      puts "==============> degrees" + degrees.inspect
      @courses = Hash.new
      degrees.each do |d|
        bdegree = BoardDegreeAssignment.where(:degree_id => d.id).first
        cdegree = DegreeCourseAssignment.where(:board_degree_assignment_id => bdegree.id)
        id_array = Array.new
        cdegree.each do |c|
          id_array << c.course_id
        end
        puts "==============> id_array" + id_array.inspect
        @courses[d.id] = Course.where("id IN (?) AND enable=true", id_array)
      end
    end
    @degrees = Degree.where(:enable => true)
    puts "=============>" + @courses.inspect
    render partial: "save_form_1"
  end

  def save_form_2
    if session[:role] != "5"
      user = User.create(name: session[:user][:name], email: session[:user][:email],
                          password: session[:user][:password], password_confirmation: session[:user][:password_confirmation],
                          phone: params[:phone], institute: params[:institute],
                          degrees: params[:degrees])
      if session[:role] == "8"
        user.teacher_token = "#{user.name.split(" ").map{|x| x[0]}.join("")}_#{(10_000 + Random.rand(100_000 - 10_000)).to_s}"
        user.save
        params[:courses].split(',').each do |course_id|
          TeacherCourse.create(user_id: user.id, course_id: course_id.to_i,
                       degree_id: Course.find(course_id.to_i).degree_course_assignments.first.board_degree_assignment.degree.id)
        end
      elsif session[:role] == "12"
        user[:courses] = params[:courses]
      end

      user.save
      Assignment.create!(user_id: user.id,role_id: session[:role].to_i)
      user.reload
      sign_in(user)
      @role = session[:role]
      puts "=============>" + @role.inspect
      @flag = true
      render partial: "save_form_2"
    else
      session[:user][:institute] = params[:institute]
      session[:user][:phone] = params[:phone]
      session[:user][:courses] = params[:courses]
      session[:user][:degree_id] = params[:degree_id]
      @courses = Course.find(params[:courses].split(','))
      render partial: "save_form_2"
    end
  end

  def save_form_3
    user_packages = params[:packages].split(',')
    session[:user][:packages] = params[:packages].split(',')
    packages = Package.where(:degree_id => session[:user][:degree_id].to_i)
    @total_price = 0
    user_packages.each do |p|
      @total_price += packages.where(:flag => p.split(':')[1]).first.price
    end
    if @total_price == 0
      user = User.create(name: session[:user][:name], email: session[:user][:email],
                          password: session[:user][:password], password_confirmation: session[:user][:password_confirmation],
                          degree_id: session[:user][:degree_id].to_i,
                          phone: session[:user][:phone], institute: session[:user][:institute])
      user[:courses] = session[:user][:courses]
      user.test_permission_ids = "1,2,3"
      user.is_active = true
      user.save
      Assignment.create!(user_id: user.id,role_id: session[:role].to_i)

      user_packages.each do |p|
        package = UserPackage.create(user_id: user.id, package_id: packages.where(:flag => p.split(':')[1]).first.id)
        course = Course.find(p.split(':')[0])
        package.name = course.name
        package.course_id = course.id
        package.plan = packages.where(:flag => p.split(':')[1]).first.name
        package.save
        if p.split(':')[1] != "1"
          package.credit_left = packages.where(:flag => p.split(':')[1]).first.price
          package.validity = 30.days.from_now
          package.save
        end
      end
      user.reload
      sign_in(user)
    end
    puts "==============>price = " + @total_price.inspect
    render partial: "save_form_3"
  end

  def registration
    if params[:request] == "1"
      user_packages = session[:user][:packages]
      packages = Package.where(:degree_id => session[:user][:degree_id].to_i)
      user = User.create(name: session[:user][:name], email: session[:user][:email],
                         password: session[:user][:password], password_confirmation: session[:user][:password_confirmation],
                         degree_id: session[:user][:degree_id].to_i,
                         phone: session[:user][:phone], institute: session[:user][:institute])
      puts "============>" + user.inspect

      user_packages.each do |p|
        package = UserPackage.create(user_id: user.id, package_id: packages.where(:flag => p.split(':')[1]).first.id)
        course = Course.find(p.split(':')[0])
        package.name = course.name
        package.course_id = course.id
        package.plan = packages.where(:flag => p.split(':')[1]).first.name
        package.save
        if p.split(':')[1] != "1"
          package.credit_left = packages.where(:flag => p.split(':')[1]).first.price
          package.validity = 30.days.from_now
          package.save
        end
      end

      user.reload
      sign_in(user)
      user.is_active = false
      user.test_permission_ids = "1,2,3"
      user[:courses] = session[:user][:courses]
      user.save
      Assignment.create!(user_id: user.id,role_id: session[:role].to_i)

      redirect_to "/user/my_profile"
    elsif params[:request] == "2"
      user_packages = session[:user][:packages]
      packages = Package.where(:degree_id => session[:user][:degree_id].to_i)
      user = User.create(name: session[:user][:name], email: session[:user][:email],
                         password: session[:user][:password], password_confirmation: session[:user][:password_confirmation],
                         degree_id: session[:user][:degree_id].to_i,
                         phone: session[:user][:phone], institute: session[:user][:institute])
      puts "============>" + user.inspect

      user_packages.each do |p|
        package = UserPackage.create(user_id: user.id, package_id: packages.where(:flag => p.split(':')[1]).first.id)
        course = Course.find(p.split(':')[0])
        package.name = course.name
        package.course_id = course.id
        package.plan = packages.where(:flag => p.split(':')[1]).first.name
        package.save
        if p.split(':')[1] != "1"
          package.credit_left = packages.where(:flag => p.split(':')[1]).first.price
          package.validity = 30.days.from_now
          package.save
        end
      end

      user.reload
      sign_in(user)
      user.is_active = false
      user.test_permission_ids = "1,2,3"
      user[:courses] = session[:user][:courses]
      user.save
      Assignment.create!(user_id: user.id,role_id: session[:role].to_i)

      redirect_to "/"
    else
      user_packages = session[:user][:packages]
      packages = Package.where(:degree_id => session[:user][:degree_id].to_i)
      user = User.create(name: session[:user][:name], email: session[:user][:email],
                         password: session[:user][:password], password_confirmation: session[:user][:password_confirmation],
                         degree_id: session[:user][:degree_id].to_i,
                         phone: session[:user][:phone], institute: session[:user][:institute])
      puts "============>" + user.inspect

      user_packages.each do |p|
        package = UserPackage.create(user_id: user.id, package_id: packages.where(:flag => p.split(':')[1]).first.id)
        course = Course.find(p.split(':')[0])
        package.name = course.name
        package.course_id = course.id
        package.plan = packages.where(:flag => p.split(':')[1]).first.name
        package.save
        if p.split(':')[1] != "1"
          package.credit_left = packages.where(:flag => p.split(':')[1]).first.price
          package.validity = 30.days.from_now
          package.save
        end
      end

      user.reload
      sign_in(user)
      user.is_active = true
      user.test_permission_ids = "1,2,3"
      user[:courses] = session[:user][:courses]
      user.save
      Assignment.create!(user_id: user.id,role_id: session[:role].to_i)

      render :json => {success: true}
    end
  end

  def user_exists
    user = User.find_by_email(params[:email])
    if user == nil
      render :json => {:success => false}
    else
      render :json => {:success => true}
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
