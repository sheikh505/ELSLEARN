class QuestionsController < ApplicationController
  load_and_authorize_resource
  before_filter :set_question, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def get_courses
    @courses = []
    id = params[:degree_id]
    list_courses = DegreeCourseAssignment.find_all_by_degree_id(id)

    list_courses.each do |course|
      @courses << Course.find_by_id(course.course_id)
    end
    render :partial => 'questions/courselist'

  end

  def get_ques
    @questions = []
    @id = params[:test_id]
    #id.tests.each {|test| @tests << test}

    Question.all.select {|x| x.test_id == @id.to_i}.each do |question|
      @questions << question
    end
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
    @questions = Question.all
    respond_with(@questions)
  end

  def show
    respond_with(@question)
  end

  def new
    @question = Question.new
    respond_with(@question)
  end

  def edit
  end

  def add_questions
   test_id = params[:test_id]
  @dc_hash = Hash.new
   test = Test.find_by_id(test_id)
   @dc_hash['degree'] = test.degree_course_assignment.degree
   @dc_hash['course'] = test.degree_course_assignment.course
    @dc_hash['test'] = test
   @questions = test.questions
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
    @questions = test.questions


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

  def create

    @question = Question.new(params[:question])
    @question.difficulty= params[:difficulty]
    @question.statement = params[:tinymce4]
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
        while(i < params[:count_option].to_i) do

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

    redirect_to add_questions_questions_path(:test_id => params[:question][:test_id])
  end

  def update
    @question.update_attributes(params[:question])
    redirect_to question_path
  end

  def destroy
    test_id = @question.test_id
    @question.destroy
    redirect_to add_questions_questions_path(:test_id => test_id)

    #redirect_to questions_path
    #respond_with(@question)
  end

  private
    def set_question
      @question = Question.find(params[:id])
    end
end
