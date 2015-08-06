class QuestionsController < ApplicationController
  before_filter :authenticate_user!, :except=>[:questions_exits]
  before_filter :set_question, :only=> [:show, :edit, :update, :destroy]
  respond_to :html, :json
  layout "admin_panel_layout"

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

    if current_user.is_admin?
      @questions = Question.search(search,page,limit)
    end

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
    render :partial=> 'ques'

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

      @boards_name = []
      @degrees_name = []
      @course_id = @question.topic.course_id

      BoardQuestionAssignment.find_all_by_question_id(@question.id).each do |bqa|
        unless @boards_name.include? bqa.board_degree_assignment.board.name
          @boards_name << bqa.board_degree_assignment.board.name
        end
        unless @degrees_name.include? bqa.board_degree_assignment.degree.name
          @degrees_name << bqa.board_degree_assignment.degree.name
        end
      end

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
    if @question.current_state == "rejected"
      @question.submit!
    end
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

  def questions_approval
    # limit = 50
    # search = ""
    # page = 1
    #
    # limit = params[:limit].to_i unless params[:limit].nil?
    # search = params[:search] unless params[:search].nil?
    # page = params[:page] unless params[:page].nil?


      respond_to do |format|
        format.html
        format.json {render :json=> QuestionsDatatable.new(view_context)}
      end
      # if current_user.teacher_courses.present?
      #   @course_id = current_user.teacher_courses.first.course_id
      #   sql = "Select *
      #            From questions q
      #            where deleted = false
      #            AND (workflow_state = 'reviewed_by_teacher'
      #            OR workflow_state = 'reviewed_by_proofreader')
      #            AND topic_id in (Select id from topics where course_id = ?)", @course_id.to_i
      #   @questions = Question.find_by_sql(sql).paginate(:page => page, :per_page => limit)
      #
      # end
#    @row = limit

  end


  @@flag = 0

  def approve_question

    @question = Question.find(params[:ques_id])
    @question.submit!

    if params[:from].present? && params[:from] == "view"
      redirect_to questions_approval_questions_path
    else
      render :json => {:success => true}
    end
  end

  def reject_question

    @question = Question.find(params[:ques_id])
    @question.reject!

    if params[:from].present? && params[:from] == "view"
      redirect_to questions_approval_questions_path
    else
      render :json => {:success => true}
    end
  end

  def add_comment_to_question
    @question = Question.find(params[:question_id])
    @question.update_attributes(:comments => params[:comments].to_s)
    if @question.save
      render :json => {:success => true}
    else
      render :json => {:success => false}
    end


  end

  def get_questions_by_status
    limit = 50
    search = ""
    page = 1

    limit = params[:limit].to_i unless params[:limit].nil?
    search = params[:search] unless params[:search].nil?
    page = params[:page] unless params[:page].nil?

    if params[:flag].to_i == 1
      @questions = Question.where(:workflow_state => "reviewed_by_proofreader").search(search,page,limit)
    elsif params[:flag].to_i == 0
      if params[:role] == "teacher"
        if @course_id = current_user.teacher_courses.present?
          @course_id = current_user.teacher_courses.first.course_id
          sql = "Select *
                 From questions q
                 where deleted = false
                 AND (workflow_state = 'reviewed_by_teacher'
                 OR workflow_state = 'reviewed_by_proofreader')
                 AND topic_id in (Select id from topics where course_id = ?)", @course_id.to_i
          @questions = Question.find_by_sql(sql).paginate(:page => page, :per_page => limit)
        end
      elsif params[:role] == "proofreader"
        sql = "Select *
                 From questions q
                 where deleted = false
                 AND (workflow_state is null)
                 Order by id "
        @questions = Question.find_by_sql(sql)
      end
      @@flag = 1
    else
      sql = "Select *
                 From questions q
                 where deleted = false
                 AND (workflow_state is null
                 OR workflow_state = 'reviewed_by_proofreader')
                 Order by id "
      @questions = Question.find_by_sql(sql).paginate(:page => page, :per_page => limit)
    end
    @row = limit

    @@flag = 1
    render :partial => 'questions/proofreader_ques'
  end

  def get_question_details_for_approval
    question_id = params[:ques_id]
    @question = Question.find(question_id)


    @boards_name = []
    @degrees_name = []
    @course_id = @question.topic.course_id

    BoardQuestionAssignment.find_all_by_question_id(question_id).each do |bqa|
      unless @boards_name.include? bqa.board_degree_assignment.board.name
        @boards_name << bqa.board_degree_assignment.board.name
      end
      unless @degrees_name.include? bqa.board_degree_assignment.degree.name
        @degrees_name << bqa.board_degree_assignment.degree.name
      end
    end


    render :partial => 'questions/question_details_for_approval'
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

  #get methods
  def questions_exits
    year = params["year"]
    session = params[:session]
    board_id = params[:board_id]
    degree_id = params[:degree_id]
    course_id = params[:course_id]
    past_paper_flag = params[:pre_Past]
    bd = BoardDegreeAssignment.find_by_board_id_and_degree_id(board_id,degree_id)
    @questions = []
    if past_paper_flag.to_i == 2
      mcq = params[:mcq]
      fill = params[:fill]
      true_false = params[:true_false]
      descriptive = params[:descriptive]
      temp = bd.questions.select{|q| q.deleted == false && q.topic.course_id == course_id.to_i}
      list = temp
      list.shuffle!
      #select number of questions according to the user requirement

      i = 0
      j = 0
      k = 0
      l = 0

      list.each do |question|
        if question.question_type == 1 && i < mcq.to_i
          @questions << question
          i += 1
        elsif question.question_type == 4 && j < true_false.to_i
          @questions << question
          j += 1
        elsif question.question_type == 3 && k < fill.to_i
          @questions << question
          k += 1
        elsif question.question_type == 9 && l < descriptive.to_i
          @questions << question
          l += 1
        end

      end
    elsif past_paper_flag.to_i == 1
      @questions = bd.questions.select{|q| q.deleted == false &&
          q.topic.course_id == course_id.to_i &&
          q.past_paper_history.present? &&
          q.past_paper_history.year == year.to_s &&
          q.past_paper_history.session == session.to_s }
    end
    if (@questions.length > 0)
      render :json => {:success => true}
    else
      render :json => {:success => false}
    end
  end

  def update_topic
    @question = Question.find(params["format"].to_i)


      if @question.update_attributes(params[:question])
       # redirect_to(:controller =>"questions", :action=>"questions_approval", :notice => 'User was successfully updated.')

        render :json => {:success => true}
      else
        #format.html { render :action => "edit" }
        render :json => {:success => false}
      end

  end
  private
    def set_question
      @question = Question.find(params[:id])
    end



  def set_question
    @question = Question.find(params[:id])
  end
end
