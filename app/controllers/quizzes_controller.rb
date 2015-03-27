class QuizzesController < ApplicationController
  load_and_authorize_resource
  before_filter :set_quiz, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @quizzes = Quiz.all
    respond_with(@quizzes)
  end

  def show
    respond_with(@quiz)
  end

  def new
    @quiz = Quiz.new
    @test_code = Devise.friendly_token.first(8)
    respond_with(@quiz,@test_code)
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
    generate_token if ModelName.exists?(token: self.token)
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
    id = params[:course_id]
    limit = 50
    search = ""
    page = 1

    limit = params[:limit].to_i unless params[:limit].nil?
    search = params[:search] unless params[:search].nil?
    page = params[:page] unless params[:page].nil?

    @questions = Question.all.select{|question| question.topic.course_id == id.to_i}

    #@questions.paginate(:page => params[:page], :per_page => 30)
    @questions = @questions.paginate :per_page => limit, :page => page
    @row = limit
    render :partial => 'tests/ques'

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
end
