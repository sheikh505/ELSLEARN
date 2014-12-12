class HomePageController < ApplicationController
  def index
  end

  def get_courses
    @courses = []
    id = params[:degree_id]
    list_courses = DegreeCourseAssignment.find_all_by_degree_id(id)

    list_courses.each do |course|
      @courses << Course.find_by_id(course.course_id)
    end
    render :partial => 'home_page/courselist'

  end

    def get_tests
      @tests = []
      id = DegreeCourseAssignment.find_by_degree_id_and_course_id(params[:degree_id],params[:course_id])
      #id.tests.each {|test| @tests << test}

      Test.all.select {|x| x.degree_course_assignment_id == id.id}.each do |test|
         @tests << test
       end
      render :partial => 'home_page/test'
    end

    def user_graph
      @user_hash = Hash.new
      @user_hash['admin'] = 10
      @user_hash['teacher'] = 10
      @user_hash['student'] = 10
      User.all.each do |user|
        if user.is_admin?
          @user_hash['admin'] += 1
        elsif user.is_teacher?
          @user_hash['teacher'] += 1
        else
          @user_hash['student'] += 1
        end

        @user_hash['total'] = @user_hash['teacher'] + @user_hash['admin'] + @user_hash['student']
        @user_hash['admin'] = @user_hash['admin'].to_f / @user_hash['total'].to_f
        @user_hash['student'] = @user_hash['student'].to_f / @user_hash['total'].to_f
        @user_hash['teacher'] = @user_hash['teacher'].to_f / @user_hash['total'].to_f



      end


    end




end
