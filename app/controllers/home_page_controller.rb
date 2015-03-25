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

    'asdfasdfasdfasdf' + params.inspect
   # asdfasdfasfasf


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
      @board_id = params[:b_id]
      @degree_id = params[:degree_id]
      @course_id = params[:course_id]
      @mcq = params[:mcq]
      @fill = params[:fill]
      @true_false = params[:true_false]
      @descriptive = params[:descriptive]


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




end
