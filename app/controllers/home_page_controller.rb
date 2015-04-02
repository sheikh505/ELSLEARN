class HomePageController < ApplicationController
  def index
    if user_signed_in? && current_user.is_admin?

    else

      @boards = Board.all
      @degrees = []
      @degrees << 'select board first'

      @courses = []
      @courses << 'select board and degree first'

      @flag = true




    end
    @notes_degrees = []
          #notes degreeesssssss
        Book.all.each do |nd|
          @notes_degrees << nd.degree
        end

    @notes_course_list = []
    @notes_list = []

  end

  def get_courses
    'asdfasdfasdfasdf' + params.inspect

    @courses = []
    degree_id = params[:degree_id]
    board_id = params[:board_id]

    @courses = BoardDegreeAssignment.find_all_by_board_id_and_degree_id(board_id,degree_id)
    @courses = @courses.last.courses
    @flag = false
    render :partial => 'home_page/c_list'

  end

  def get_degrees
    board_ids = params[:board_ids]
    ids = board_ids.split('-')
    @degrees = []
    temp = Board.select{|board| ids.include? (board.id.to_s)}

    temp.each do |board|

      board.degrees.each do |degree|
        @degrees << degree

      end
    end


    #board = Board.find_by_id(board_id)
    #@degrees = board.degrees
    @degrees.uniq!
    @flag = false
    render :partial => 'home_page/d_list'

  end

  def instructions
    puts "--------------->", params.inspect
    @board_id = params[:b_id]
    @degree_id = params[:degree_id]
    @course_id = params[:course_id]
    @mcq = params[:mcq]
    if params[:fill].blank?
      @fill = 0
    else
      @fill = params[:fill]
    end
    if params[:true_false].blank?
      @true_false = 0
    else
      @true_false = params[:true_false]
    end
    if params[:descriptive].blank?
      @descriptive = 0
    else
      @descriptive = params[:descriptive]
    end
    if user_signed_in?
      @user = current_user
    else
      @user = User.new
    end


  end

  def quiz


    @board_id = params[:b_id]
    @degree_id = params[:degree_id]
    @course_id = params[:course_id]
    @mcq = params[:mcq]
    @fill = params[:fill]
    @true_false = params[:true_false]
    @descriptive = params[:descriptive]

    #@questions = []

    if user_signed_in?
      @register = false

    bd = BoardDegreeAssignment.find_by_board_id_and_degree_id(@board_id,@degree_id)
    temp = bd.questions
    @questions = []
    list = temp.select{|q| q.deleted == false && q.topic.course_id == @course_id.to_i}
    list.shuffle!
    #select number of questions according to the user requirement

    i = 0
    j = 0
    k = 0
    l = 0

    list.each do |question|
      if question.question_type == 1 && i < @mcq.to_i
        @questions << question
        i += 1
      elsif question.question_type == 4 && j < @true_false.to_i
        @questions << question
        j += 1
      elsif question.question_type == 3 && k < @fill.to_i
        @questions << question
        k += 1
      elsif question.question_type == 9 && l < @descriptive.to_i
        @questions << question
        l += 1
      end

    end

    @size = @questions.length
    @index = 0

    else
      @user = User.new
      @register = true
    end
    render layout: "quiz_layout"

  end

  def add_user_test

    user_history = UserTestHistory.new(score: params[:score],total: params[:total],course: Course.find_by_id(params[:course]).name,user_id: current_user.id,code: nil)
    user_history.save

    redirect_to root_path

  end

  def create_user_registration
    unless user_signed_in?
      @user = User.new(params[:user])
      @user.save

      sign_in @user

      assignment = Assignment.new(user_id: @user.id,role_id: Role.find_by_name('Student').id)
      assignment.save
    end


    redirect_to :action => 'quiz',b_id: params[:b_id],degree_id: params[:degree_id],course_id: params[:course_id],mcq: params[:mcq],true_false: params[:true_false],fill: params[:fill],descriptive: params[:descriptive]
  end

  def sign_in_user
    if user_signed_in?
      redirect_to :action => 'quiz',b_id: params[:b_id],degree_id: params[:degree_id],course_id: params[:course_id],mcq: params[:mcq],true_false: params[:true_false],fill: params[:fill],descriptive: params[:descriptive]
    else
      user = User.find_by_email(params[:new_user][:email])
      if user.present? && user.valid_password?(params[:new_user][:password])
        sign_in user
        render :json => {:success => true}
      else
        render :json => {:success => false}
      end
    end
  end

  def is_user_signed_in
    if user_signed_in?
      render :json => {:success => true}
    else
      render :json => {:success => false}
    end
  end

  def next
    @index = params[:index].to_i
    @index = @index + 1

    render :partial => 'quiz_ques'
  end

  def notes_courses

    degree_id = params[:degree_id]
    @notes_course_list = []

    Book.all.each do |book|

      @notes_course_list << book.course if book.degree_id == degree_id.to_i

    end
    render :partial => 'notes_courses'

  end

  def get_notes

    degree_id = params[:degree_id]
    course_id = params[:course_id]
    @notes_list = []

    Book.all.each do |book|

      @notes_list << book if book.degree_id == degree_id.to_i && book.course_id == course_id.to_i

    end
    render :partial => 'notes'


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

    end


  private
  def check_session

  end

end
