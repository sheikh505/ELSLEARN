class CoursesController < ApplicationController
  load_and_authorize_resource
  before_filter :set_course, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @courses = Course.all
    respond_with(@courses)
  end

  def show
    respond_with(@course)
  end

  def new
    @course = Course.new
    respond_with(@course)
  end

  def edit
  end

  def create
    @course = Course.new(params[:course])
    @course.save
    @ass = DegreeCourseAssignment.new(:course_id => @course.id, :degree_id => params[:degree])
    @ass.save
    redirect_to courses_path
  end

  def update
    @course.update_attributes(params[:course])
    respond_with(@course)
  end

  def destroy
    @course.destroy
    respond_with(@course)
  end

  private
    def set_course
      @course = Course.find(params[:id])
    end
end
