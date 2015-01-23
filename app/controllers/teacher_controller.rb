class TeacherController < ApplicationController
  respond_to :html, :xml, :json

  def index

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
        @teacher_course = TeacherCourse.new(degree_course_assignment_id: @dcaId.id, :user_id => params[:user][:user_id])
        @teacher_course.save
      end
    else
      puts "--------------> Value cannot be null"
    end
    redirect_to teacher_index_path
  end



  def new
    @user = User.new

  end

  def edit
    @user = User.find_by_id(params[:id])

  end

  def show
    @user = User.find_by_id(params[:id])
  end

  def create
    puts "----------------------->", params.inspect()
    @user = User.new(params[:user])
    if @user.save
      redirect_to teacher_courses_teacher_index_path(:id => @user.id)
    else
      redirect_to new_teacher_path(@user)
    end

  end

  def update
    @user = User.find_by_id(params[:id])
    if params[:user][:password] == ''
      @user.update_attributes(:email => params[:user][:email],
                              :name => params[:user][:name],
                              :phone => params[:user][:phone]
      )
      @user.save
    else
      @user.update_attributes(:email => params[:user][:email],
                              :name => params[:user][:name],
                              :phone => params[:user][:phone],
                              :password => params[:user][:password]

      )
      @user.save

    end
    redirect_to teacher_index_path
  end
end
