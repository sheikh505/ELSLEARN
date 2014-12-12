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
    respond_with(@test)
  end

  def edit
  end

  def create
    @id = DegreeCourseAssignment.find_by_course_id_and_degree_id(params[:course],params[:degree])
    @id=@id.id;

    @test = Test.new(params[:test])
    @test.degree_course_assignment_id = @id
    @test.save
    respond_with(@test)
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
