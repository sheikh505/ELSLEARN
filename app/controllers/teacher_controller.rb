class TeacherController < ApplicationController
  respond_to :html, :xml, :json
  layout "admin_panel_layout"
  before_filter :set_user, :only=> [:show, :edit, :update, :destroy]

  def index
    @user = current_user
    if @user.is_proofreader?
      @users = User.where(:role => @user.id.to_s)
    else
      @roles = Role.all
      @roles = @roles.select{ |role|
        role.name != "Admin"
      }
      puts "===============> " + @roles.inspect
      @users = User.joins("INNER JOIN assignments a ON users.id = a.user_id").where("a.role_id = ?", @roles.first.id)
    end
  end

  def fetch_users

    @users = User.joins("INNER JOIN assignments a ON users.id = a.user_id").where("a.role_id = ?", params[:role_id])
    render partial: "fetch_users"


  end

  def check_quiz

    @tests = UserTestHistory.where("(teacher_id = ? OR teacher_id = -1) AND reviewed = false AND video_review = true", current_user.id).order('created_at DESC')
    # @students = User.where("id IN (?)", @tests.pluck(:user_id))
    @courses = Course.where("id IN (?)", @tests.pluck(:course_id))

    #reviewed quizzes
    @reviewed_tests = UserTestHistory.where("teacher_id = ? AND reviewed = true AND video_review = true", current_user.id).order('created_at DESC')
    @reviewed_test_courses = Course.where("id IN (?)", @reviewed_tests.pluck(:course_id))

  end

  def student_test

    @test = UserTestHistory.find(params[:test_id])
    session[:user_test_history_id] = @test.id
    #@questions = Question.where("id IN (?)", @test.descriptive.split(','))

    # descriptive question ids
    question_ids = @test.descriptive
    puts "===============> " + question_ids.inspect
    # session[:question_ids] = question_ids
    redirect_to student_review_question_path(question_ids: question_ids, test_id: @test.id)

  end

  def save_remarks
    answer = Answer.find(params[:answer_id])
    question_ids = params[:question_ids]
    answer.update_attributes(:marks => params[:marks].to_i , :remarks => params[:remarks], :reviewed => true)
    redirect_to student_review_question_path(test_id: answer.user_test_history_id, question_ids: question_ids)
  end

  def finish_review
    answer = Answer.find(params[:answer_id])
    answer.update_attributes(:marks => params[:marks].to_i , :remarks => params[:remarks], :reviewed => true)
    test = UserTestHistory.find(params[:test_id])
    test.update_attributes(:reviewed => true, teacher_id: current_user.id)
    answers = Answer.where(user_test_history_id: test.id)
    obtained_marks = 0
    answers.each do |answer|
      if answer.marks
        obtained_marks = obtained_marks + answer.marks
      else

      end
    end
    test.update_attributes(:score => test.score + obtained_marks)
    if test.video_review
      redirect_to '/check_quiz'
    else
      redirect_to '/comment_feedback'
    end
  end

  def reviewed_quizzes
    @tests = UserTestHistory.where("teacher_id = ? AND reviewed = true AND video_review = false", current_user.id).order('created_at DESC')
    # @students = User.where("id IN (?)", @tests.pluck(:user_id))
    @courses = Course.where("id IN (?)", @tests.pluck(:course_id))
  end

  def video_reviewed_quizzes
    @tests = UserTestHistory.where("teacher_id = ? AND reviewed = true AND video_review = true", current_user.id).order('created_at DESC')
    # @students = User.where("id IN (?)", @tests.pluck(:user_id))
    @courses = Course.where("id IN (?)", @tests.pluck(:course_id))
  end

  def review_question
    @question_ids = params[:question_ids].nil? ? []:params[:question_ids].split(',')
    @question = Question.find(@question_ids.pop)
    @finish_flag = @question_ids.count == 0 ? true : false

    # puts "==============>" + @question_ids.pop.inspect, @question.inspect
    @option = @question.options.first
    @question_ids = @question_ids.join(',')
    @test = UserTestHistory.find(params[:test_id])
    @answer = Answer.where(question_id: @question.id, user_test_history_id: @test.id).first
    if @answer.reviewed
      redirect_to student_review_question_path(test_id: @test.id, question_ids: @question_ids)
      return
    end
    puts "==============>" + @answer.inspect
    session[:answer_id] = @answer.id
    if @test.video_review
      render "video_review_question"
    else
      if @answer.answer_images.present?
        @image = @answer.answer_images.first
        @images = @answer.answer_images
        session[:image_ids] = @answer.answer_images.pluck(:id)
        @image_ids = session[:image_ids]
        puts "==============>" + @image.inspect, @image_ids.inspect
      end
      render "review_question"
    end
  end

  def next_image
    session[:image_ids] = session[:image_ids] - [session[:image_ids][0]]
    puts "==============>" + session[:image_ids].inspect, session[:image_ids].class.inspect
    @image = AnswerImage.find_by_id(session[:image_ids])
    @image_ids = session[:image_ids]
    answer = @image.answer
    @images = answer.answer_images
    puts "==============>" + @image.inspect, @image_ids.inspect

    respond_to do |format|
      format.html {  render partial: "edit_image", locals: {imagee: @image, imagee_ids: @image_ids, imagees: @images} }
      format.js
    end
  end

  def comment_feedback
    @tests = UserTestHistory.where("(teacher_id = ? OR teacher_id = -1) AND reviewed = false AND video_review = false", current_user.id).order('created_at DESC')
    @students = User.where("id IN (?)", @tests.pluck(:user_id))
    @courses = Course.where("id IN (?)", @tests.pluck(:course_id))

    #reviewed quizzes
    @reviewed_tests = UserTestHistory.where("teacher_id = ? AND reviewed = true AND video_review = false", current_user.id).order('created_at DESC')
    # @students = User.where("id IN (?)", @tests.pluck(:user_id))
    @reviewed_test_courses = Course.where("id IN (?)", @reviewed_tests.pluck(:course_id))
  end

  def preview_reviewed_quiz
    @test = UserTestHistory.find(params[:test_id])
    session[:user_test_history_id] = @test.id
    question_ids = @test.descriptive.split(',')
    session[:question_ids] = question_ids
    @questions = Question.where("id IN (?)", @test.descriptive.split(','))
    if @questions.first
      redirect_to teachers_preview_question_path
    else
      flash[:error] = "There are no descriptive questions in this test."
      redirect_to :back
    end
  end

  def preview_question
    @question = Question.find(session[:question_ids].pop)
    @finish_flag = session[:question_ids].count == 0 ? true : false
    @test = UserTestHistory.find(session[:user_test_history_id])
    @answer = Answer.where(user_test_history_id: @test.id, question_id: @question.id).first
  end

  def upload_video
    answer = Answer.find(params[:id])
    answer.video = params[:record][:video]
    answer.save
    render json: {success: true}
  end

  def upload_image
    answer_image = AnswerImage.find_by_id(params[:answer_id])
    if answer_image
      answer_image.update_attribute(:image, params[:image])
    end
    render :nothing => true
  end

  # def fetch_image
  #   @answer = Answer.find(params[:answer_id])
  #   @image = IMGKit.new(@answer.detail)
  #   format.jpg do
  #     send_data(@image.to_jpg, :type => "image/jpeg", :disposition => 'inline')
  #   end
  # end

  def destroy

    @user.destroy
    redirect_to "/user"

  end

  def get_courses
    @courses = []
    @list_courses = []
    id = params[:degree_id]

    @arr = BoardDegreeAssignment.find_all_by_degree_id(id)

    if @arr
      @arr.each do |bDegree|
        @list_courses << bDegree.courses;
      end
    end

    @list_courses.each do |course|
      course.each do |i|
        @courses << i
      end

    end
    @courses = @courses.uniq();

    render :partial => 'teacher/courselist'

  end

  def teacher_courses
    @user = User.find_by_id(params[:id])
    @boards = Board.all



  end

  def course_register
    unless params[:boards].nil? && params[:degree].nil? && params[:course].nil?
      params[:boards].each do |board|

        @bdaId = BoardDegreeAssignment.find_by_board_id_and_degree_id(board,params[:degree])
        @dcaId = DegreeCourseAssignment.find_by_course_id_and_board_degree_assignment_id(params[:course],@bdaId.id)
        @teacher_course = TeacherCourse.new(:degree_course_assignment_id=> @dcaId.id, :user_id => params[:user][:user_id])
        @teacher_course.save
      end
    else
      puts "--------------> Value cannot be null"
    end
    redirect_to teacher_index_path
  end



  def new
    unless @user.present?
      @user = User.new
    end
    if current_user.is_admin?
      @roles = Role.all
    else
      @roles = Role.where(:name => "Operator")
    end
    @degrees = Degree.all
    @courses = Course.all


    @proofreaders = User.joins(:roles).where('roles.name' => 'Proof Reader')
  end

  def edit
    @user = User.find_by_id(params[:id])
    @roles = Role.all
    if @user.roles.present?
      @user_role_id = @user.roles.first.id
    end
    @degrees = Degree.all
    @courses = Course.all
    @teacher_courses = @user.teacher_courses.select("course_id, degree_id")
    @proofreaders = User.joins(:roles).where('roles.name' => 'Proof Reader')
    @user_packages = @user.user_packages
  end

  def show
    @user = User.find_by_id(params[:id])
  end

  def create
    params[:test_permission_ids] = params[:test_permission_ids].values
    params[:test_permission_ids] = params[:test_permission_ids].join(",")
    puts "uhh<><><><><???????",params[:test_permission_ids].inspect

    @user = User.new(params[:user])
    # @user.role = params[:role_id]
    @role_id = params[:role_id]





    if @user.save
      if current_user.is_proofreader?
        role_id = Role.find_by_name("Operator").id
        @role_id = role_id
      end
      assignment = {'user_id'=>@user.id,'role_id'=>@role_id}
      @assignment = Assignment.new(assignment)
      @assignment.save
      if @role_id != 0
        unless @user.is_operator?
          @user.update_attributes(:role => 0)
        end

        if @role_id == "5"
          @user.update_attributes(:role => @role_id, :test_permission_ids => params[:test_permission_ids])

        end

        if @user.is_teacher?

          @user.teacher_token = "#{@user.name.split(" ").map{|x| x[0]}.join("")}_#{(10_000 + Random.rand(100_000 - 10_000)).to_s}"
          @user.review_permission_ids = params[:review_permission_ids].values.join(',')
          @user.save
          @degrees = Degree.all
          if @degrees.present?
            @degrees.each do |degree|
              course_id = params["course_#{degree.id}"]
              puts "=============<><><><><>",course_id.inspect
              course_id.each do |course|
                teacher_course = {'user_id'=>@user.id, 'degree_id'=>degree.id, 'course_id'=>course}
                puts "================>>>>>>>>>",teacher_course.inspect
                @teacher_course = TeacherCourse.new(teacher_course)
                @teacher_course.save
              end unless course_id.nil?
            end
          end


        elsif @user.is_hod?
          @user.update_attribute(:review_permission_ids, "1,2,3")
          course_list = params[:course]
          if course_list.present?
            course_list.each do |course|
              teacher_course = {'user_id'=>@user.id, 'degree_id'=>0, 'course_id'=>course}
              @teacher_course = TeacherCourse.new(teacher_course)
              @teacher_course.save
            end
          else
            TeacherCourse.where(:user_id=>@user.id).delete_all
          end
        end
      end
      redirect_to "/user"
    else
      if current_user.is_admin?
        @roles = Role.all
      else
        @roles = Role.where(:name => "Operator")
      end
      @degrees = Degree.all
      @courses = Course.all


      @proofreaders = User.joins(:roles).where('roles.name' => 'Proof Reader')
      respond_with(@user)
    end

  end

  def update
    @user = User.find_by_id(params[:id])
    if(@user.present?)
      if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
      end
      if params[:test_permission_ids]
        params[:test_permission_ids] = params[:test_permission_ids].values
        params[:test_permission_ids] = params[:test_permission_ids].join(",")
        @user.test_permission_ids = params[:test_permission_ids]
        @user.save
      end
      if params[:package]
        params[:package].each do |key, value|
          package = UserPackage.find_by_id(key)
          if package
            package.update_attribute(:credit_left, value.to_i)
          end
        end

      end
      @user.update_attributes(params[:user])
    end
    @role_id = params[:role_id]
    @user_role_id = params[:user_role_id]

    if @user_role_id != @role_id
      if @user.assignments.present?
        @user.assignments.first.update_attributes(:role_id => @role_id)
      else
        assignment = {'user_id'=>@user.id,'role_id'=>@role_id}
        @assignment = Assignment.new(assignment)
        @assignment.save
      end
    end
    unless @user.is_operator?
      @user.update_attributes(:role => 0)
    end
    if @user.is_teacher?
      @user.update_attribute(:review_permission_ids, params[:review_permission_ids].values.join(','))
      puts "==============================>" + @user.inspect
      degrees = params[:degree]
      course_id = params[:course]
      if degrees.present?
        degrees = params[:degree].first
        @teacher_courses = @user.teacher_courses.select("id,user_id, course_id, degree_id")
        @teacher_courses.each do |teacher_course|
          unless degrees.include? teacher_course.degree_id.to_s
            teacher_course.delete
          else
            degrees.each do |key,degree|
              course_list = params["course_#{degree}"]
              if course_list.present?
                unless course_list.include? teacher_course.course_id.to_s && teacher_course.degree_id == degree
                  teacher_course.delete
                end
              elsif teacher_course.degree_id == degree
                teacher_course.delete
              end
            end
          end
        end
        degrees.each do |key,degree|
          course_id = params["course_#{degree}"]
          if course_id.present?
            course_id.each do |course|
              teacher_course = {'user_id'=>@user.id, 'degree_id'=>key, 'course_id'=>course}
              unless TeacherCourse.where(teacher_course).present?
                @teacher_course = TeacherCourse.new(teacher_course)
                @teacher_course.save
              end
            end
          end
        end
      else
        TeacherCourse.where(:user_id=>@user.id).delete_all
      end
    elsif @user.is_hod?
      course_list = params[:course]
      if course_list.present?
        @teacher_courses = @user.teacher_courses.select("id,user_id, course_id, degree_id")
        @teacher_courses.each do |teacher_course|
          unless course_list.include? teacher_course.course_id.to_s
            teacher_course.delete
          end
        end
        course_list.each do |course|
          teacher_course = {'user_id'=>@user.id, 'degree_id'=>0, 'course_id'=>course}
          unless TeacherCourse.where(teacher_course).present?
            @teacher_course = TeacherCourse.new(teacher_course)
            @teacher_course.save
          end
        end
      else
        TeacherCourse.where(:user_id=>@user.id).delete_all
      end
    end

    redirect_to "/user"
  end

  def new_students
    if current_user.is_teacher?
      @new_students = TeacherRequest.where(teacher_token: current_user.teacher_token,status: 'PENDING')
    else
      redirect_to root_path
    end
  end

  def manage_students
    if current_user.is_teacher?
      @students = TeacherRequest.where(teacher_token: current_user.teacher_token,status: 'SUCCESSFUL')
    else
      redirect_to root_path
    end
  end

  def accept_student
    @flag = false
    respond_to do |format|
      if params[:id].nil?
      @message = "NO RECORD FOUND"
      else
        @teacher_request = TeacherRequest.find(params[:id])
        if @teacher_request.nil?
          @message = "NO RECORD FOUND"
        else
          @teacher_request.update_attribute(:status,"SUCCESSFUL")
          @flag = true
          @row_id = "#row_#{@teacher_request.id}"
          @message = "ACCEPTED SUCCESSFULLY"
        end
      end

      format.js
    end
  end

  def reject_student
    @flag = false
    respond_to do |format|
      if params[:id].nil?
        @message = "NO RECORD FOUND"
      else
        @teacher_request = TeacherRequest.find(params[:id])
        if @teacher_request.nil?
          @message = "NO RECORD FOUND"
        else
          @teacher_request.update_attribute(:status,"FAILED")
          @flag = true
          @row_id = "#row_#{@teacher_request.id}"
          @message = "REJECTED SUCCESSFULLY"
        end
      end
      format.js
    end
  end
  private
  def set_user
    @user = User.find(params[:id])
  end
end
