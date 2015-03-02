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


    end

  def quiz

    @board_id = params[:b_id]
    @degree_id = params[:degree_id]
    @course_id = params[:course_id]
    #@questions = []

    bd = BoardDegreeAssignment.find_by_board_id_and_degree_id(@board_id,@degree_id)
    temp = bd.questions

    @questions = temp.select{|q| q.deleted == false}
    @size = @questions.length
    @index = 0


  end

  def next

    @index = params[:index].to_i
    @index = @index + 1

    render :partial => 'quiz_ques'

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
