class QuestionsController < ApplicationController
  load_and_authorize_resource
  before_filter :set_question, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def get_courses

    id = params[:course_id]

    @board_degrees = DegreeCourseAssignment.find_all_by_course_id(id)
    @boards = []
    @degrees = []

    @board_degrees.each do |board_degree|
    @boards << board_degree.board_degree_assignment.board
    end

    @board_degrees.each do |board_degree|
      @degrees << board_degree.board_degree_assignment.degree
    end

    @boards = @boards.uniq
    @degrees = @degrees.uniq

    render :partial => 'questions/board_degree'

  end

  def get_ques
    @questions = []
    @id = params[:test_id]
    #id.tests.each {|test| @tests << test}

    Question.all.select {|x| x.deleted == false && x.test_id == @id.to_i}.each do |question|
      @questions << question
    end
    render :partial => 'questions/ques'
  end

  def delete_ques
    @question = Question.find(params[:ques_id])
    @question.deleted = true
    @question.save
    @id = @question.test_id
    @questions = Question.all.select {|x| x.deleted == false && x.test_id == @id.to_i}
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



  def index
    @board = Board.new
    @board_hash = @board.board_degree_hash


    @questions = Question.all.select{|x| x.deleted == false}
    respond_with(@questions)
  end

  def show
    if @question.deleted == false
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
    #test_id = params[:test_id]
    @dc_hash = Hash.new
    test = Test.find_by_id(@question.test.id)
    @dc_hash['degree'] = test.degree_course_assignment.degree
    @dc_hash['course'] = test.degree_course_assignment.course
    @dc_hash['test'] = test
    if @question.question_type == 1
    @dc_hash["ques_type"] = 'MCQ'
    elsif @question.question_type == 2
      @dc_hash["ques_type"] = 'Descriptive'
      elsif @question.question_type == 3
        @dc_hash["ques_type"] = 'Fill in the blank'
        elsif @question.question_type == 4
          @dc_hash["ques_type"] = 'True False'
        else
          @dc_hash["ques_type"] = 'Undefined'
          end

    @topics = Topic.all.select {|x| x.degree_course_assignment_id == test.degree_course_assignment_id}
    @view = @question.question_type


  end

  def add_questions
   test_id = params[:test_id]
  @dc_hash = Hash.new
   test = Test.find_by_id(test_id)
   @dc_hash['degree'] = test.degree_course_assignment.degree
   @dc_hash['course'] = test.degree_course_assignment.course
    @dc_hash['test'] = test
   @questions = test.questions.select{|x| x.deleted == false}
   @question = Question.last
   @topics = Topic.all.select {|x| x.degree_course_assignment_id == test.degree_course_assignment_id}
   @view = 1
    @view = params[:view] unless params[:view].nil?
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


    @question = Question.new(params[:question])
    @question.difficulty= params[:difficulty]
    @question.statement = params[:tinymce4]
    @question.topic_id = params[:topic]
    @question.deleted = false
   @question.author = current_user.email
    if @question.save

      if params[:pastPaperFlag] == '1'
        @past_paper = PastPaperHistory.new(:flag => params[:pastPaperFlag],
                             :paper => params[:paper],
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

          option = Option.new(
                             :statement => params['option_'+i.to_s],
                             :avatar => params['option_image_'+i.to_s],
                             :flag => params['image_change_'+i.to_s],
                             :question_id => @question.id,
                             :is_answer =>params['is_answer_'+i.to_s]
          )
          if option.avatar_file_name.nil?
          option.save
          else
            option.avatar_file_name = (Time.now.to_i).to_s + '_' + option.avatar_file_name
            option.save
          end
        i = i + 1
        end

          option.inspect
      elsif params[:type_ques] == 'trueFalse'
        @option = Option.new(:statement => params[:option],:question_id => @question.id,:is_answer => params[:is_answer])
        @option.save
      else

        @option = Option.new(:statement => params[:answer],:question_id => @question.id,:is_answer => 1)
        @option.save

      end

    end

   # redirect_to add_questions_questions_path(:test_id => params[:question][:test_id])
   respond_with(@question)
  end

  def update


    @question.update_attributes(params[:question])
    @question.difficulty= params[:difficulty]
    @question.statement = params[:tinymce4]
    @question.topic_id = params[:topic]
    @question.author = current_user.email
    @question.save
    if @question.past_paper_history.nil?

      if params[:pastPaperFlag] == '1'
        @past_paper = PastPaperHistory.new(:flag => params[:pastPaperFlag],
                                           :paper => params[:paper],
                                           :ques_no => params[:ques_no],
                                           :session => params[:session],
                                           :year => params[:year],
                                           :question_id => @question.id
        )
        @past_paper.save
      end

    else
      @question.past_paper_history.update_attributes(:flag => params[:pastPaperFlag],
                                                     :paper => params[:paper],
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

        option.update_attributes(
            :statement => params['option_'+i.to_s],
            :avatar => params['option_image_'+i.to_s],
            :flag => params['image_change_'+i.to_s],
            :question_id => @question.id,
            :is_answer =>params['is_answer_'+i.to_s]
        )

        unless option.avatar_file_name.nil?
          option.avatar_file_name = (Time.now.to_i).to_s + '_' + option.avatar_file_name

        end
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


    test_id = @question.test_id
    @question.deleted = true
    @question.save
    # @question.destroy
    redirect_to questions_path

    #redirect_to questions_path
    #respond_with(@question)
  end

  private
    def set_question
      @question = Question.find(params[:id])
    end
end
