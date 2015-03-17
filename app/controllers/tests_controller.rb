class TestsController < ApplicationController
  load_and_authorize_resource
  before_filter :set_test, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @tests = Test.all
    respond_with(@tests)
  end

  def show
    respond_with(@test)
  end

  def new
    @test = Test.new
    @test_code = Devise.friendly_token.first(8)
    limit = 50
    search = ""
    page = 1

    limit = params[:limit].to_i unless params[:limit].nil?
    search = params[:search] unless params[:search].nil?
    page = params[:page] unless params[:page].nil?

    @questions = Question.search(search,page,limit)
    @row = limit
    respond_with(@test,@test_code)
  end

  def edit
  end

  def create
    course_id = params[:course]
    test_code = params[:test_code]
    @test = Test.new(params[:test])
    @test.course_id = course_id
    @test.test_code = test_code
    @test.user_id = current_user.id

    @test.save
    redirect_to tests_path
  end

  def update
    @test.update_attributes(params[:test])
    respond_with(@test)
  end

  def destroy
    @test.destroy
    respond_with(@test)
  end
  def get_courses
    @courses = []
    id = params[:degree_id]
    list_courses = DegreeCourseAssignment.find_all_by_degree_id(id)

    list_courses.each do |course|
      @courses << Course.find_by_id(course.course_id)
    end


    render :partial => 'tests/courselist'

  end

  private
    def set_test
      @test = Test.find(params[:id])
    end
end
