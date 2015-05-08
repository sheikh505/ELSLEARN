class TeacherController < ApplicationController
  respond_to :html, :xml, :json
  layout "admin_panel_layout"

  def index
    @user = current_user
    if @user.is_proofreader?
      @users = User.where(:role => @user.id.to_s)
    else
      @users = User.all
    end

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
        @teacher_course = TeacherCourse.new(:degree_course_assignment_id=> @dcaId.id, :user_id => params[:user][:user_id])
        @teacher_course.save
      end
    else
      puts "--------------> Value cannot be null"
    end
    redirect_to teacher_index_path
  end



  def new
    @user = User.new
    if current_user.is_admin?
      @roles = Role.all
    else
      @roles = Role.where(:name => "Operator")
    end
    @degrees = Degree.all
    @courses = Course.all
  end

  def edit
    @user = User.find_by_id(params[:id])
    @roles = Role.all
    @user_role_id = @user.roles.first.id
    @degrees = Degree.all
    @courses = Course.all
    @teacher_courses = @user.teacher_courses.select("course_id, degree_id")
  end

  def show
    @user = User.find_by_id(params[:id])
  end

  def create
    @user = User.new(params[:user])
    @role_id = params[:role_id]

    if @user.save
      assignment = {'user_id'=>@user.id,'role_id'=>@role_id}
      @assignment = Assignment.new(assignment)
      @assignment.save
      degrees = params[:degree]
      course_id = params[:course]
      if degrees.present?
        degrees.each do |degree|
          teacher_course = {'user_id'=>@user.id, 'degree_id'=>degree, 'course_id'=>course_id}
          @teacher_course = TeacherCourse.new(teacher_course)
          @teacher_course.save
        end
      end
      redirect_to teacher_index_path
    else
      redirect_to new_teacher_path(@user)
    end

  end

  def update

    @user = User.find_by_id(params[:id])
    if(@user.present?)
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
    end
    @role_id = params[:role_id]
    @user_role_id = params[:user_role_id]

    if @user_role_id != @role_id
      @user.assignments.first.update_attributes(:role_id => @role_id)
      @user.assignments.first.save
    end
    degrees = params[:degree]
    course_id = params[:course]
    if degrees.present?
      @teacher_courses = @user.teacher_courses.select("id,user_id, course_id, degree_id")
      @teacher_courses.each do |teacher_course|
        unless degrees.include? teacher_course.degree_id.to_s
          TeacherCourse.find(teacher_course.id).delete
        end
      end
      degrees.each do |degree|
        teacher_course = {'user_id'=>@user.id, 'degree_id'=>degree, 'course_id'=>course_id}
        unless TeacherCourse.where(teacher_course).present?
          @teacher_course = TeacherCourse.new(teacher_course)
          @teacher_course.save
        end
      end
    else
      TeacherCourse.where(:user_id=>@user.id).delete_all
    end
    redirect_to teacher_index_path
  end
end
