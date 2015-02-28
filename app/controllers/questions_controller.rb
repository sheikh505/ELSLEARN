class QuestionsController < ApplicationController
  load_and_authorize_resource
  before_filter :set_question, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def get_courses
    @boards = []
    @degrees = []

    id = params[:course_id]
      unless id > '0'
      @boards = Board.all
      @degrees = Degree.all

    else
      @board_degrees = DegreeCourseAssignment.find_all_by_course_id(id)


      @board_degrees.each do |board_degree|
        @boards << board_degree.board_degree_assignment.board
      end

      @board_degrees.each do |board_degree|
        @degrees << board_degree.board_degree_assignment.degree
      end

      @boards = @boards.uniq
      @degrees = @degrees.uniq
    end


    render :partial => 'questions/board_degree'

  end

  def get_ques
    @questions = []
    #@id = params[:test_id]
    #id.tests.each {|test| @tests << test}

    Question.all.select {|x| x.deleted == false }.each do |question|
      @questions << question
    end

   # @questions = Question.paginate(:page => params[:page], :per_page => 30)
    render :partial => 'questions/ques'
  end

  def delete_ques

    @question = Question.find(params[:ques_id])
    @question.deleted = true
    @question.save
    #@id = @question.test_id

    limit = 50
    search = ""
    page = 1

    @questions = Question.search(search,page,limit)
    @row = limit


    render :partial => 'questions/ques'
  end

  def get_tests
    @tests = []
    id = DegreeCourseAssignment.find_by_degree_id_and_course_id(params[:degree_id],params[:course_id])
    #id.tests.each {|test| @tests << test}

    Test.all.select {|x| x.degree_course_assignment_id == id.id}.each do |test|
      @tests << test
    end
    render :partial => 'questions/test'
  end

  def demo
    @question = Question.find_by_id(params[:ques_id])

    if @question.question_type == 1
      type = 'MCQ'
    elsif @question.question_type == 3
      type = 'Fill In The Blank'
    else @question.question_type == 4
      type = 'True False'
    end
    @options = @question.options
    @options = @options.shuffle
    @question_heading =  type + ' - ' + @question.topic.course.name.to_s
    @alpha = []
    @alpha << 'a'
    @alpha << 'b'
    @alpha << 'c'
    @alpha << 'd'

  end

  def index

    session[:question] = nil
    @board = Board.new
    @board_hash = @board.board_degree_hash

    limit = 50
    search = ""
    page = 1

    limit = params[:limit].to_i unless params[:limit].nil?
    search = params[:search] unless params[:search].nil?
    page = params[:page] unless params[:page].nil?

    @questions = Question.search(search,page,limit)
    @row = limit
   # @questions = Question
    #@questions = Question.paginate(:page => params[:page], :per_page => 2)
    #respond_with(@questions)
  end

  def get_limit

    limit = 4
    search = ""
    page = 1

    limit = params[:limit].to_i unless params[:limit].nil?
    search = params[:search] unless params[:search].nil?
    page = params[:page] unless params[:page].nil?

    @questions = Question.search(search,page,limit)
    render partial: 'ques'

  end

  def show
    if @question.deleted == false
      @boards = []
      @degrees = []
      @question.board_degree_assignments.each do |bd|
          @boards << bd.board_id
          @degrees << bd.degree_id
      end

      @boards = @boards.uniq
      @degrees = @degrees.uniq

      session[:question] ||= {}
      session[:question][:course_id] = @question.topic.course_id
      session[:question][:boards] = @boards
      session[:question][:degrees] = @degrees
      session[:question][:view] = @question.question_type.to_s

    respond_with(@question)
    else
    redirect_to questions_path
    end

  end

  def new
    @question = Question.new
    respond_with(@question)
  end

  def edit
    @question = Question.find_by_id(params[:id])

    @topic = @question.topic
    @course_id = @topic.course_id
    @boards = []
    @degrees = []
    dummy = @question.board_degree_assignments

    dummy.each do |bdgree|
      @boards << bdgree.board
    end

    dummy.each do |bdgree|
      @degrees << bdgree.degree
    end

    @boards = @boards.uniq
    @degrees = @degrees.uniq

    @view = @question.question_type
    @view = @view.to_s()
    @topics = Course.find_by_id(@course_id).topics

    #test_id = params[:test_id]


  end

  def add_questions

    @question = Question.new
    
    if session[:question].nil?
      @course_id = params[:course]
      @boards = params[:boards]
      @degrees = params[:degree]
      @view = params[:question_type]
    else
      @course_id = session[:question][:course_id]
      @boards = session[:question][:boards]
      @degrees = session[:question][:degrees]
      @view = session[:question][:view]
    end

    unless params[:q_id].nil?
      @ques_id = params[:q_id]
      @flag = 1
      @question = Question.find_by_id(params[:q_id])
      @question_no = @question.past_paper_history.ques_no unless @question.past_paper_history.nil?
      @question_no = @question_no.to_i
      @question_no += 1
    end




    @topics = Course.find_by_id(@course_id).topics
    @boards_name = []
    @boards.each do |board|
      @boards_name << Board.find_by_id(board).name
    end

    @degrees_name = []
    @degrees.each do |degree|
      @degrees_name << Degree.find_by_id(degree).name
    end


  end

  def render_view


    test_id = params[:test_id]
    @dc_hash = Hash.new
    test = Test.find_by_id(test_id)
    @dc_hash['degree'] = test.degree_course_assignment.degree
    @dc_hash['course'] = test.degree_course_assignment.course
    @dc_hash['test'] = test
    @questions = test.questions.select{|x| x.deleted == false}
    @topics = Topic.all.select {|x| x.degree_course_assignment_id == test.degree_course_assignment_id}

    id = params[:ques_type]

    if id == '1'
      render :partial => 'questions/mcq'
    elsif id == '2'
      render :partial => 'questions/descriptive'
    elsif id == '3'
      render :partial => 'questions/blank'
    else
      render :partial => 'questions/truefalse'
    end
  end


  def render_view_edit


    test_id = params[:test_id]
    @dc_hash = Hash.new
    test = Test.find_by_id(test_id)
    @dc_hash['degree'] = test.degree_course_assignment.degree
    @dc_hash['course'] = test.degree_course_assignment.course
    @dc_hash['test'] = test
    @question = Question.find_by_id(params[:ques_id])
    @topics = Topic.all.select {|x| x.degree_course_assignment_id == test.degree_course_assignment_id}

    id = params[:ques_type]

    if id == '1'
      render :partial => 'questions/mcq_edit'
    elsif id == '2'
      render :partial => 'questions/descriptive_edit'
    elsif id == '3'
      render :partial => 'questions/blank_edit'
    else
      render :partial => 'questions/truefalse_edit'
    end
  end

  def create


    @boards = params[:boards]
    @degrees = params[:degrees]

    @boards = @boards.split(" ")
    @degrees = @degrees.split(" ")



    @question = Question.new(params[:question])
    @question.difficulty= params[:difficulty]
    @question.statement = params[:tinymce4]
    @question.description = params[:tinymce5]
    #@question.topic_id = params[:topic_id]
    @question.test_id = nil
    @question.deleted = false
   @question.author = current_user.email
    if @question.save

      if params[:pastPaperFlag] == '1'
        @past_paper = PastPaperHistory.new(:flag => params[:pastPaperFlag],
                             :ques_no => params[:ques_no],
                             :session => params[:session],
                             :year => params[:year],
                             :question_id => @question.id
        )
        @past_paper.save
      end

      if params[:type_ques] == 'mcq'
        ##logic for mcqs questions

        i = 1
        while(i <= params[:count_option].to_i) do
          if params['is_answer_'+i.to_s] == '1'
            is_answer = params['is_answer_'+i.to_s]
          else
            is_answer = '0'
          end
          option = Option.new(
                             :statement => params['option_'+i.to_s],
                             :avatar => params['option_image_'+i.to_s],
                             :flag => params['image_change_'+i.to_s],
                             :question_id => @question.id,
                             :is_answer =>  is_answer
          )
          if option.avatar_file_name.nil?
          option.save
          else
            option.avatar_file_name = (Time.now.to_i).to_s + '_' + option.avatar_file_name
            option.save
          end
        i = i + 1
        end


      elsif params[:type_ques] == 'trueFalse'
        @option = Option.new(:statement => params[:option],:question_id => @question.id,:is_answer => params[:is_answer])
        @option.save
      else

        @option = Option.new(:statement => params[:answer],:question_id => @question.id,:is_answer => 1)
        @option.save

      end

      ## register boards and degrees
      @boards.each do |board_id|
        @degrees.each do |degree_id|
          bdegree = BoardDegreeAssignment.find_by_board_id_and_degree_id(board_id, degree_id)
          unless bdegree.nil?
            qs = BoardQuestionAssignment.new(:board_degree_assignment_id => bdegree.id,
                                              :question_id => @question.id)
            qs.save
          end
        end
      end

    end

    session[:question] ||= {}
    session[:question][:course_id] = params[:course_id]
    session[:question][:boards] = @boards
    session[:question][:degrees] = @degrees
    session[:question][:view] = params[:view]


    # redirect_to add_questions_questions_path(:test_id => params[:question][:test_id])
   respond_with(@question)
  end

  def update




    @question.update_attributes(params[:question])
    @question.difficulty= params[:difficulty]
    @question.statement = params[:tinymce4]
    @question.description = params[:tinymce5]
   # @question.topic_id = params[:topic_id]
    @question.author = current_user.email
    @question.save
    if @question.past_paper_history.nil?

      if params[:pastPaperFlag] == '1'
        @past_paper = PastPaperHistory.new(:flag => params[:pastPaperFlag],
                                          #:paper => params[:paper],
                                           :ques_no => params[:ques_no],
                                           :session => params[:session],
                                           :year => params[:year],
                                           :question_id => @question.id
        )
        @past_paper.save
      end

    else
      @question.past_paper_history.update_attributes(:flag => params[:pastPaperFlag],
                                                     #:paper => params[:paper],
                                                     :ques_no => params[:ques_no],
                                                     :session => params[:session],
                                                     :year => params[:year],
                                                     :question_id => @question.id
      )
    end

    if params[:type_ques] == 'mcq'
      ##logic for mcqs questions
      i = 1
      @question.options.each do |option|
        if params['is_answer_'+i.to_s] == '1'
            is_answer = params['is_answer_'+i.to_s]
        else
          is_answer = '0'
        end

        option.update_attribute(:statement, params['option_'+i.to_s])
        option.update_attribute(:avatar, params['option_image_'+i.to_s]) unless params['option_image_'+i.to_s].nil?
        option.update_attribute(:flag, params['image_change_'+i.to_s])
        option.update_attribute(:question_id, @question.id)
        option.update_attribute(:is_answer, is_answer)

        option.save
        i = i + 1

      end



    elsif params[:type_ques] == 'trueFalse'
      @question.options.last.update_attributes(:statement => params[:option],:question_id => @question.id,:is_answer => params[:is_answer])

    else

      @question.options.last.update_attributes(:statement => params[:answer],:question_id => @question.id,:is_answer => 1)


    end


    redirect_to question_path(@question)
  end

  def destroy


   # test_id = @question.test_id
    @question.deleted = true
    @question.save
    # @question.destroy
    #redirect_to questions_path

    #redirect_to questions_path
    #respond_with(@question)
  end

  private
    def set_question
      @question = Question.find(params[:id])
    end
end
