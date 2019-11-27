class UserController < ApplicationController
  def new
  end

  def save_result
    if params[:user_test_history][:id].to_i == 0
      user_history = UserTestHistory.new(params[:user_test_history])
      user_history.save
    else
      @test = UserTestHistory.find(params[:user_test_history][:id])
      @test.score = params[:score]
      @test.total = params[:total]
      @test.is_live = false
      @test.save
    end
    redirect_to user_dashboard_path
  end

  def my_profile

    @user = User.find(current_user.id)
    @news_feed = NewsFeed.last
    @last_user_history = UserTestHistory.find_all_by_user_id(@user.id).last

  end

  def test_reviews
    @user = current_user
    @tests = current_user.user_test_histories.where('reviewed = true').order('created_at DESC')
    @courses = Course.where("id IN (?)", @tests.pluck(:course_id))
  end

  def quiz_answers
    @test = UserTestHistory.find(params[:test_id])
    session[:user_test_history_id] = @test.id
    question_ids = []
    if @test.mcq
      question_ids = @test.mcq.split(',')
    end
    if @test.fill
      @test.fill.split(',').each do |ques|
        question_ids << ques
      end
    end
    if @test.truefalse
      @test.truefalse.split(',').each do |ques|
        question_ids << ques
      end
    end
    if @test.descriptive
      @test.descriptive.split(',').each do |ques|
        question_ids << ques
      end
    end
    session[:question_ids] = question_ids
    redirect_to student_show_answer_path
  end

  def show_answer
    question_id = session[:question_ids].pop
    @test = UserTestHistory.find(session[:user_test_history_id])
    puts "==============>"+question_id.inspect
    if question_id.include? ":"
      @student_choice = question_id.split(':')[1]
      @question = Question.find(question_id.split(':')[0])
      @options = @question.options
    else
      @question = Question.find(question_id)
    end
    @finish_flag = session[:question_ids].count == 0 ? true : false
    @answer = Answer.where(user_test_history_id: @test.id, question_id: @question.id).first
  end

  def submit_feedback
    test = UserTestHistory.find(session[:user_test_history_id])
    test.update_attributes(:student_feedback => params[:student_feedback])
    render partial: "submit_feedback"
  end

  def update
    @user = User.find current_user.id

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(:controller =>"user", :action=>"my_profile", :notice => 'User was successfully updated.') }
        format.json { respond_with_bip(@user) }
      else
        format.html { render :action => "edit" }
        format.json { respond_with_bip(@user) }
      end
    end
  end

  def update_password
    @user = User.find(current_user.id)
    respond_to do |format|
      if @user.update_with_password(params[:user])
        # Sign in the user by passing validation in case their password changed
        sign_in @user, :bypass => true
        format.html { redirect_to(:controller =>"user", :action=>"my_profile", :notice => 'User was successfully updated.') }
        format.json { respond_with_bip(@user) }
      else
        format.html { redirect_to(:controller =>"user", :action=>"my_profile", :notice => @user.errors.full_messages) }
        format.json { respond_with_bip(@user) }
      end
    end
  end

  def manage_courses
    # degree_id= Degree.where("degre_id=?", @degree.id)
    # bdgree = BoardDegreeAssignment.where(:degree_id => current_user.degree_id)
    # course_ids = DegreeCourseAssignment.where(:board_degree_assignment_id => 20).pluck(:course_id)
    # @courses = Course.find_all_by_id(course_ids)
    # # # @user_course_ids = current_user[:courses].split(',')
    @packages = UserPackage.where(user_id: current_user.id)
  end

  def delete_package

    package = UserPackage.find(params[:id])
    courses = current_user[:courses].split(',')
    puts "==============>"+courses.inspect
    courses.delete(package.course_id.to_s)
    puts "==============>"+courses.inspect
    current_user[:courses] = courses.join(",")
    puts "==============>"+current_user[:courses].inspect
    current_user.save
    package.delete
    @packages = UserPackage.where(user_id: current_user.id)
    render partial: "delete_package"
  end

  def add_course

    bdgree = BoardDegreeAssignment.where(:degree_id => current_user.degree_id)
    course_ids = DegreeCourseAssignment.where(:board_degree_assignment_id => bdgree.first.id).pluck(:course_id)
    if current_user[:courses]
      user_courses = current_user[:courses].split(',')
      user_courses.each do |id|
        if course_ids.include?(id.to_i)
          course_ids.delete(id.to_i)
        end
      end
      @courses = Course.find_all_by_id_and_enable(course_ids, true)
    else
      @courses = Course.find_all_by_id_and_enable(course_ids, true)
    end

  else

    # puts "==============>",params[:course_id].inspect,bdgree.inspect,course_ids.inspect,user_courses.inspect,@courses.inspect
    render partial: "add_course"

  end

  def fetch_packages
    session[:course_id] = params[:course_id]
    @course = Course.find(params[:course_id])
    render partial: "fetch_packages"
  end

  def buy


    degree_id = current_user.degree_id
    plan = params[:plan]
    session[:plan] = params[:plan]
    @price = Package.where(degree_id: degree_id, flag: plan).first
    if @price == 0
      degree_id = current_user.degree_id

      packages = Package.where( degree_id: degree_id, flag: session[:plan].to_i).first
      package = UserPackage.create(user_id: current_user.id, package_id: packages.id)
      course = Course.find(session[:course_id])
      courses = current_user[:courses].split(',')
      courses << course.id.to_s
      current_user[:courses] = courses.join(',')
      current_user.save
      package.name = course.name
      package.course_id = course.id
      package.plan = packages.name
      package.save
    end
    render partial: "buy"
  end

  def purchase



    debugger

    degree_id = current_user.degree_id

    packages = Package.where( degree_id: degree_id, flag: session[:plan].to_i)

    package = UserPackage.create(user_id: current_user.id, package_id: packages.first.id)

    course = Course.find(session[:course_id])
   # course= current_user.all
          if current_user[:courses]
      courses = current_user[:courses].split(',')
      courses << course.id.to_s
      current_user[:courses] = courses.join(',')
      current_user.save
    else
      current_user[:courses] = course.id.to_s
      current_user.save
    end

    debugger

    package.name = course.name
    package.course_id = course.id
    package.plan = packages.name
    package.save
    if session[:plan] != "1"
      # package.credit_left = packages.price

      package.validity = 30.days.from_now
      package.save
    end

    render json: {success: true}

  end

  def update_courses
    if params[:courses]
      current_user[:courses] = params[:courses].join(',')
      current_user.save
      redirect_to "/user/my_profile"
    else
      current_user[:courses] = params[:courses]
      current_user.save
      redirect_to "/user/my_profile"
    end
  end

  def dashboard
    @user = User.find(current_user.id)
    @user_test_histories = UserTestHistory.where(:user_id => @user.id).order('created_at DESC')
  end

  def ReTakeTest

    user_test_history_id = params[:user_test_history_id]
    @user_test_histories = UserTestHistory.find(user_test_history_id)
    redirect_to :action => 'quiz', :controller => "home_page", :user_test_history_id=>user_test_history_id
    # :b_id=> @user_test_histories[:board_id],
    # :degree_id=> @user_test_histories[:degree_id],
    # :course_id=> @user_test_histories[:course],:mcq=> @user_test_histories[:mcq],
    # :true_false=> @user_test_histories[:truefalse],:fill=> @user_test_histories[:fill],
    # :descriptive=> @user_test_histories[:descriptive], :pre_Past=> @user_test_histories[:pastpaperflag],
    # :year=> @user_test_histories[:year], :session=> @user_test_histories[:session]

  end

  def request_teacher
    respond_to do |format|
      # check if already exist
      arr = TeacherRequest.where(student_id: params[:teacher_request][:student_id],teacher_token: params[:teacher_request][:teacher_token],status: 'PENDING')
      if arr.blank?
        @teacher_request = TeacherRequest.new(params[:teacher_request])
        if @teacher_request.save
          @flag = true
          @message = "REQUEST SENT SUCCESSFULLY"
        else
          @flag = false
          @message = @teacher_request.errors.full_messages.first
        end
      else
        @message = "REQUEST ALREADY EXIST"
      end

      format.js
    end
  end


  def get_courses_by_degree_id

    debugger

    @degree_id_selected = params[:degree_id].to_i
    puts "----------course=======",@degree_id_selected.inspect
    sql = "Select distinct c.id, name From courses c Inner join degree_course_assignments dca on c.id = dca.course_id Inner join board_degree_assignments bda on dca.board_degree_assignment_id = bda.id
          where degree_id = ?", @degree_id_selected

    # result = ActiveRecord::Base.connection.execute(sql)

    @courses_selected = Course.find_by_sql(sql)
    puts "-===========-=",@courses_selected.inspect
    render :partial => 'users/registrations/get_course'

  end


  def progress

  end


  private

  def user_params
    # NOTE: Using `strong_parameters` gem
    params.required(:user).permit(:password, :password_confirmation)
  end

end
