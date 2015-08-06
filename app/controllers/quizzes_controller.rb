class QuizzesController < ApplicationController
  before_filter :set_quiz, :only=> [:show, :edit, :update, :destroy]
  before_filter :check_session, :except => [:test_exists]

  layout "admin_panel_layout"
  respond_to :html

  def index
    @quizzes = Quiz.where(:user_id => current_user.id)
    respond_with(@quizzes)
  end

  def show
    respond_with(@quiz)
  end

  def new
    @quiz = Quiz.new
    @test_code = Devise.friendly_token.first(8)

    respond_with(@quiz, @test_code)


  end

  def edit
  end

  def create
    @quiz = Quiz.new(params[:quiz])
    @quiz.user_id = current_user.id

    @quiz.save
    redirect_to quizzes_path
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

    @questions = Question.select("questions.*,topics.name as topic_name,courses.name as course_name").
        joins(:topic => :course).
        where("course_id = ? and workflow_state = 'accepted'", @course_id)
    render :partial => 'quizzes/questions_list'
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

  private
    def set_quiz
      @quiz = Quiz.find(params[:id])
    end
  def check_session

  end
end
