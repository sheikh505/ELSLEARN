class CoursesController < ApplicationController
  load_and_authorize_resource
  before_filter :set_course, :only => [:show, :edit, :update, :destroy]
  layout "admin_panel_layout"
  respond_to :html

  def index
      debugger
    @degrees = Degree.all

    bdegree = BoardDegreeAssignment.find_by_degree_id(@degrees.first.id)
    course_ids = DegreeCourseAssignment.where(board_degree_assignment_id: bdegree.id).pluck(:course_id)
    @courses = Course.find(course_ids)

    @degree_hash = {}

    @courses.each do |course|
      @degree_hash["#{course.id}::#{course.name}"] = course.board_degree_assignments

    end

    respond_with(@courses)
  end


  def manage_courses
    @degrees = Degree.all

    bdegree = BoardDegreeAssignment.find_by_degree_id(@degrees.first.id)
    course_ids = DegreeCourseAssignment.where(board_degree_assignment_id: bdegree.id).pluck(:course_id)
    @courses = Course.find(course_ids)

    @degree_hash = {}

    @courses.each do |course|
      @degree_hash["#{course.id}::#{course.name}"] = course.board_degree_assignments
    end
    render partial: "manage_courses"
  end

  def fetch_courses
    bdegree = BoardDegreeAssignment.find_by_degree_id(params[:degree_id])
    course_ids = DegreeCourseAssignment.where(board_degree_assignment_id: bdegree.id).pluck(:course_id)
    @courses = Course.find(course_ids)

    @degree_hash = {}

    @courses.each do |course|

      @degree_hash["#{course.id}::#{course.name}"] = course.board_degree_assignments
    end

    render partial: "fetch_courses"
  end

  def show
    respond_with(@course)
  end

  def new
    @course = Course.new
    @boards = @course.board_degree_assignments
    @board_hash = Hash.new
     BoardDegreeAssignment.all.each do |bdgree|
      @board_hash[bdgree.id] = bdgree.board.name + "  (" + bdgree.degree.name + ")"
     end


    render partial: "new"
  end

  def edit

    @boards = @course.board_degree_assignments
    @board_hash = Hash.new
    BoardDegreeAssignment.all.each do |bdgree|
      @board_hash[bdgree.id] = bdgree.board.name + "  (" + bdgree.degree.name + ")"
    end

    render partial: "edit"

  end

  def create

    @course = Course.new(name: params[:name], enable: params[:enable])
    @course.name.upcase!
    if @course.save
      params[:boards].each do |bDegree|
        ass = DegreeCourseAssignment.new(:course_id => @course.id, :board_degree_assignment_id => bDegree)
        ass.save
      end
    end

    redirect_to action: :manage_courses
  end

  def update

    params[:name].upcase!
    @course.update_attributes(name: params[:name], enable: params[:enable])
    if params[:boards] != nil
      board = params[:boards]
      @arr = DegreeCourseAssignment.find_all_by_course_id(@course.id)

      @arr.each do |bDegree|
        bDegree.destroy unless board.find {|x| x == bDegree.board_degree_assignment_id}

      end

      params[:boards].each do |board|
        unless @arr.find {|x| x.board_degree_assignment_id == board }
          ass = DegreeCourseAssignment.new(:course_id => @course.id, :board_degree_assignment_id => board)
          ass.save
        end

      end
    else
      @arr = DegreeCourseAssignment.find_all_by_course_id(@course.id)

      @arr.each do |bDegree|
      end
    end


    redirect_to action: :manage_courses
  end

  def destroy
    @course.destroy
    @courses = Course.all
    @degree_hash = {}

    @courses.each do |course|
      @degree_hash["#{course.id}::#{course.name}"] = course.board_degree_assignments
    end
    render partial: "manage_courses"
  end

  def get_courses_by_degree_id
    @degree_id = params[:degree_id].to_i
    sql = "Select distinct c.id, name
          From courses c
          Inner join degree_course_assignments dca on c.id = dca.course_id
          Inner join board_degree_assignments bda on dca.board_degree_assignment_id = bda.id
          where degree_id = ?", @degree_id
    @courses = Course.find_by_sql(sql)
    @user = User.find(current_user.id)
    if params[:user_id].present?
      @user = User.find(params[:user_id])
      @teacher_courses = @user.teacher_courses.select("course_id, degree_id")

    end
    render :partial => 'courselist'
  end

  private
    def set_course
      @course = Course.find(params[:id])
    end
end
