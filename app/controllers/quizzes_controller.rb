class QuizzesController < ApplicationController
  before_filter :set_quiz, :only=> [:show, :edit, :update, :destroy]
  before_filter :check_session, :except => [:test_exists]

  layout "admin_panel_layout", except: [:show]
  respond_to :html

  def index
    if current_user.is_admin?
      @degrees = Degree.all

      bdegree = BoardDegreeAssignment.find_by_degree_id(@degrees.first.id)
      course_ids = DegreeCourseAssignment.where(board_degree_assignment_id: bdegree.id).pluck(:course_id)
      @courses = Course.find(course_ids)
      @quizzes = Quiz.where(:course_id => @courses.first.id)
      respond_with(@quizzes)
    else
      @quizzes = Quiz.where(:user_id => current_user.id)
      respond_with(@quizzes)
    end
  end

  def fetch_courses
    bdegree = BoardDegreeAssignment.find_by_degree_id(params[:degree_id])
    course_ids = DegreeCourseAssignment.where(board_degree_assignment_id: bdegree.id).pluck(:course_id)
    @courses = Course.find(course_ids)

    render partial: "fetch_courses"
  end

  def fetch_quizzes
    @quizzes = Quiz.where(course_id: params[:course_id])
    render partial: "fetch_quizzes"
  end

  def show
    @questions = Question.find(@quiz.question_ids.split(","))
    @user = @quiz.user
    @count = Hash.new(0)
    @questions.each do |question|
      if question.question_type == 1
        @count[:mcq] += 1
      elsif question.question_type == 3
        @count[:fill] += 1
      elsif question.question_type == 4
        @count[:truefalse] += 1
      elsif question.question_type == 2
        @count[:descriptive] += 1
      end
    end
    @time_allowed = @quiz.time_allowed
    @bdgree = @quiz.course.board_degree_assignments.first

    students = TeacherRequest.where(teacher_token: current_user.teacher_token,status: 'SUCCESSFUL')

    @students = Array.new
    if students.first != nil
      students.each do |student|
        s = Hash.new
        s[:student_name] = student.student_name
        test = User.find(student.student_id).user_test_histories.where(:code => @quiz.test_code).last
        if test
          if test.score == nil
            test.score = 0
            test.save
          end
          if test.total == nil
            test.total = 0
            test.save
          end
          s[:score] = test.score
          s[:total] = test.total
          s[:percentage] = (((test.score+0.0)/test.total)*100).round(2)
          if s[:percentage].nan?
            s[:percentage] = 0.0
          end
          if s[:percentage] >= 90
            s[:grade] = "A*"
          elsif s[:percentage] >=85 && s[:percentage] < 90
            s[:grade] = "A"
          elsif s[:percentage] >=75 && s[:percentage] < 85
            s[:grade] = "B"
          elsif s[:percentage] >=65 && s[:percentage] < 75
            s[:grade] = "C"
          elsif s[:percentage] >=55 && s[:percentage] < 65
            s[:grade] = "D"
          elsif s[:percentage] >=45 && s[:percentage] < 55
            s[:grade] = "E"
          elsif s[:percentage] < 45
            s[:grade] = "F"
          end
          @students << s
        end
      end
    end
    render 'show', :layout => "application2" and return
  end

  def new
    @quiz = Quiz.new
    @test_code = Devise.friendly_token.first(8)
    if current_user.is_admin?
      @courses = Course.all
    else
      if current_user.teacher_courses.present?
        course_ids = current_user.teacher_courses.pluck(:course_id)
        @courses = Course.find_all_by_id(course_ids)
      else
        @courses = []
      end
    end

    respond_with(@quiz, @test_code)
  end

  def edit
  end

  def create
    @quiz = Quiz.new(params[:quiz])
    @quiz.user_id = current_user.id
    @quiz.time_allowed = @quiz.question_ids.split(',').count * 1.5
    if @quiz.save
      redirect_to quizzes_path
    else
      if current_user.is_admin?
        @courses = Course.all
      else
        if current_user.teacher_courses.any?
          course_ids = current_user.teacher_courses.pluck(:course_id)
          @courses = Course.find_all_by_id(course_ids)
        else
          @courses = []
        end
      end
      respond_with(@quiz)
    end
  end

  def generate_token
    self.token = SecureRandom.urlsafe_base64
    generate_token if ModelName.exists?(:token=> self.token)
  end

  def get_courses
    @courses = []
    id = params[:degree_id]
    list_courses = DegreeCourseAssignment.find_all_by_degree_id(id)

    list_courses.each do |course|
      @courses << Course.find_by_id(course.course_id)
    end

    render :partial => 'Test/courselist'

  end

  def get_questions
    @course_id = params[:course_id]
    @questions = Question.select("questions.*").
        joins(:course_linking).
        where("(course_1  IN (?) OR course_2  IN (?) OR course_3  IN (?) OR course_4  IN (?)) and author = ? and workflow_state = 'accepted'", @course_id, @course_id, @course_id, @course_id,current_user.email)
    render :partial => 'quizzes/questions_list'
  end

  def get_els_questions
    @course_id = params[:course_id]
    @questions = Question.select("questions.*").
        joins(:course_linking).
        where("(course_1  IN (?) OR course_2  IN (?) OR course_3  IN (?) OR course_4  IN (?)) and workflow_state = 'accepted' and question_type in (?)", @course_id, @course_id, @course_id, @course_id,params[:ques_types].split(","))
    @questions.shuffle!
    if @questions.size == 0
      render :json => {:success => false}.to_json
    else
      @question = @questions.pop
      ids = @questions.pluck(:id).shuffle.join(",")
      render :json => {:success => true,html: render_to_string(partial: 'quizzes/pop_up'),:question_ids => ids}.to_json
    end
  end

  def test_exists
    test_code = params["test_code"]
    if (Quiz.find_by_test_code(test_code).present?)
      render :json => {:success => true}
    else
      render :json => {:success => false}
    end
  end

  def update
    @quiz.update_attributes(params[:quiz])
    respond_with(@quiz)
  end

  def destroy
    @quiz.destroy
    respond_with(@quiz)
  end

  def get_topics
    @topics = Topic.where(course_id: params[:course_id])
    render :partial => 'topic_list'
  end

  def get_next_question
    @question = Question.find(params[:question_id])
    render :partial => 'pop_up'
  end

  private
  def set_quiz
    @quiz = Quiz.find(params[:id])
  end
  def check_session

  end
end
