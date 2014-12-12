class TeacherController < ApplicationController


  def index

  end

  def get_courses
    @courses = []
    id = params[:degree_id]
    list_courses = DegreeCourseAssignment.find_all_by_degree_id(id)

    list_courses.each do |course|
      @courses << Course.find_by_id(course.course_id)
    end


    render :partial => 'teacher/courselist'

  end

  def teacher_courses
    @user = User.find_by_id(params[:id])



  end

  def course_register
    @id = DegreeCourseAssignment.find_by_course_id_and_degree_id(params[:course],params[:degree])
  @teacher_course = TeacherCourse.new(degree_course_assignment_id: @id.id, :user_id => params[:user][:user_id])
  @teacher_course.save
    redirect_to teacher_courses_teacher_index_path(:id => params[:user][:user_id])
  end



  def new
  @user = User.new

  end

  def edit
    @user = User.find_by_id(params[:id])

  end
  def show

  end
  def create
    @user = User.new(params[:user])
    @user.save
    redirect_to teacher_courses_teacher_index_path(:id => @user.id)
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
