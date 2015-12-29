class CourseLinkingsController < ApplicationController
  load_and_authorize_resource
  before_filter :set_course_linking, only: [:show, :edit, :update, :destroy]
  layout "admin_panel_layout"
  respond_to :html

  def index
    @course_linkings = CourseLinking.all
    respond_with(@course_linkings)
  end

  def show
    respond_with(@course_linking)
  end

  def new
    @course_linking = CourseLinking.new
    arr = []
    CourseLinking.all.each do |x|

      arr << x.course_1 unless x.course_1.nil?
      arr << x.course_2 unless x.course_2.nil?
      arr << x.course_3 unless x.course_3.nil?
      arr << x.course_4 unless x.course_4.nil?

    end
    arr.uniq!

    if arr.blank?
      @courses = Course.order(:name)
    else
      @courses = Course.where("id NOT IN (#{arr.join(",")})").order(:name)
    end

    respond_with(@course_linking)
  end

  def edit
    arr = []
    CourseLinking.all.each do |x|
      unless @course_linking.id == x.id
        arr << x.course_1 unless x.course_1.nil?
        arr << x.course_2 unless x.course_2.nil?
        arr << x.course_3 unless x.course_3.nil?
        arr << x.course_4 unless x.course_4.nil?
      end
    end
    arr.uniq!

    if arr.blank?
      @courses = Course.order(:name)
    else
      @courses = Course.where("id NOT IN (#{arr.join(",")})").order(:name)
    end
  end

  def create
    arr = params[:course_linking].values
    arr = arr.select{|x| x != ""}
    if arr.size == arr.uniq().size
      @course_linking = CourseLinking.new(params[:course_linking])
      @course_linking.save
      redirect_to course_linkings_path
    else
      redirect_to "/course_linkings/new",alert: "DUPLICATE COURSES"
    end
  end

  def update
    @course_linking.update_attributes(params[:course_linking])
    redirect_to course_linkings_path
  end

  def destroy
    @course_linking.destroy
    respond_with(@course_linking)
  end

  private
  def set_course_linking
    @course_linking = CourseLinking.find(params[:id])
  end
end
