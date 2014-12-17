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

    course_id = Course.find_by_name(params[:course][:name])

    unless course_id.nil?
      if DegreeCourseAssignment.find_by_course_id_and_degree_id(course_id.id , params[:degree]).nil?

        @course = Course.new(params[:course])
        @course.save
        @ass = DegreeCourseAssignment.new(:course_id => @course.id, :degree_id => params[:degree])
        @ass.save
      end

    else
      @course = Course.new(params[:course])
      @course.save
      @ass = DegreeCourseAssignment.new(:course_id => @course.id, :degree_id => params[:degree])
      @ass.save
    end

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
