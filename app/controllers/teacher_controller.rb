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

  def destroy
    @user.destroy
    respond_with(@user)
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

      @degrees = Degree.all
      if @degrees.present?
        @degrees.each do |degree|
          course_id = params["course_#{degree.id}"]
          course_id.each do |course|
            teacher_course = {'user_id'=>@user.id, 'degree_id'=>degree.id, 'course_id'=>course}
            @teacher_course = TeacherCourse.new(teacher_course)
            @teacher_course.save
          end
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
    if @user.is_teacher?
      degrees = params[:degree]
      course_id = params[:course]
      if degrees.present?
        degrees = params[:degree].first
        @teacher_courses = @user.teacher_courses.select("id,user_id, course_id, degree_id")
        @teacher_courses.each do |teacher_course|
          unless degrees.include? teacher_course.degree_id.to_s
            teacher_course.delete
          else
            degrees.each do |key,degree|
              course_list = params["course_#{degree}"]
              if course_list.present?
                unless course_list.include? teacher_course.course_id.to_s && teacher_course.degree_id == degree
                  teacher_course.delete
                end
              elsif teacher_course.degree_id == degree
                teacher_course.delete
              end
            end


          end
        end
        degrees.each do |key,degree|
          course_id = params["course_#{degree}"]
          if course_id.present?
            course_id.each do |course|
              teacher_course = {'user_id'=>@user.id, 'degree_id'=>key, 'course_id'=>course}
              unless TeacherCourse.where(teacher_course).present?
                @teacher_course = TeacherCourse.new(teacher_course)
                @teacher_course.save
              end
            end
          end
        end
      else
        TeacherCourse.where(:user_id=>@user.id).delete_all
      end
    elsif @user.is_hod?
      course_list = params[:course]
      if course_list.present?
        @teacher_courses = @user.teacher_courses.select("id,user_id, course_id, degree_id")
        @teacher_courses.each do |teacher_course|
          unless course_list.include? teacher_course.course_id.to_s
            teacher_course.delete
          end
        end
        course_list.each do |course|
          teacher_course = {'user_id'=>@user.id, 'degree_id'=>0, 'course_id'=>course}
          unless TeacherCourse.where(teacher_course).present?
            @teacher_course = TeacherCourse.new(teacher_course)
            @teacher_course.save
          end
        end
      else
        TeacherCourse.where(:user_id=>@user.id).delete_all
      end
    end

    redirect_to edit_teacher_path(@user)
  end
end
