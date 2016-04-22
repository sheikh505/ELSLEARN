class QuestionsController < ApplicationController
  before_filter :authenticate_user!, :except => [:questions_exits]
  before_filter :set_question, :only => [:show, :edit, :update, :destroy]
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

    Question.all.select { |x| x.deleted == false }.each do |question|
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

    @questions = Question.search(search, page, limit)
    @row = limit
    render :partial => 'questions/ques'
  end



  def get_tests
    @tests = []
    id = DegreeCourseAssignment.find_by_degree_id_and_course_id(params[:degree_id], params[:course_id])
    #id.tests.each {|test| @tests << test}

    Test.all.select { |x| x.degree_course_assignment_id == id.id }.each do |test|
      @tests << test
    end
    render :partial => 'questions/test'
  end

  def demo
    @question = Question.find_by_id(params[:ques_id])
    @alpha = []
    if @question.question_type == 1
      type = 'MCQ'
      @alpha << 'a'
      @alpha << 'b'
      @alpha << 'c'
      @alpha << 'd'
    elsif @question.question_type == 3
      type = 'Fill In The Blank'
      @alpha = 'Answer'
    elsif @question.question_type == 4
      type = 'True False'
      @alpha << 'Answer'
    else
      type = 'Descriptive'
      @alpha << 'Answer'
    end
    @options = @question.options
    @options = @options.shuffle

    unless CourseLinking.find_by_id(@question.course_linking_id).nil?
      course1 = Course.find_by_id(CourseLinking.find_by_id(@question.course_linking_id).course_1).name.blank? ? "nil" : Course.find_by_id(CourseLinking.find_by_id(@question.course_linking_id).course_1).name
      course2 = Course.find_by_id(CourseLinking.find_by_id(@question.course_linking_id).course_2).name.nil? ? "nil" : Course.find_by_id(CourseLinking.find_by_id(@question.course_linking_id).course_2).name
      course3 = Course.find_by_id(CourseLinking.find_by_id(@question.course_linking_id).course_3).name.nil? ? "nil" : Course.find_by_id(CourseLinking.find_by_id(@question.course_linking_id).course_3).name
      course4 = Course.find_by_id(CourseLinking.find_by_id(@question.course_linking_id).course_4).name.nil? ? "nil" : Course.find_by_id(CourseLinking.find_by_id(@question.course_linking_id).course_4).name
      @question_heading = type + ' - ' + course1 + ", " + course2 + ", " + course3 + ", " + course4
    end

    # @question_heading = type + ' - ' + Course.find_by_id(CourseLinking.find_by_id(@question.course_linking_id).course_1).name + ", " + Course.find_by_id(CourseLinking.find_by_id(@question.course_linking_id).course_2).name + ", " + Course.find_by_id(CourseLinking.find_by_id(@question.course_linking_id).course_3).name + ", " + Course.find_by_id(CourseLinking.find_by_id(@question.course_linking_id).course_4).name


  end

  def index
    session[:question] = nil
    @board = Board.new
    @board_hash = @board.board_degree_hash

    if current_user.is_admin?
      respond_to do |format|
        format.html
        format.json { render :json => QuestionsDatatable.new(view_context) }
      end

    elsif current_user.is_teacher?
      respond_to do |format|
        format.html
        format.json { render :json => QuestionsDatatable.new(view_context) }
      end
    end
  end

  def get_limit

    limit = 4
    search = ""
    page = 1

    limit = params[:limit].to_i unless params[:limit].nil?
    search = params[:search] unless params[:search].nil?
    page = params[:page] unless params[:page].nil?

    @questions = Question.search(search, page, limit)
    render :partial => 'ques'

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
      # @course_id = @question.topic.course_id

      BoardQuestionAssignment.find_all_by_question_id(@question.id).each do |bqa|
        unless @boards_name.include? bqa.board_degree_assignment.board.name
          @boards_name << bqa.board_degree_assignment.board.name
        end
        unless @degrees_name.include? bqa.board_degree_assignment.degree.name
          @degrees_name << bqa.board_degree_assignment.degree.name
        end
      end

      session[:question] ||= {}
      # session[:question][:course_id] = @question.topic.course_id
      session[:question][:course_id] = @question.course_linking_id
      session[:question][:boards] = @boards
      session[:question][:degrees] = @degrees
      session[:question][:view] = @question.question_type.to_s

      @question_histories = @question.question_histories
      @question_histories.each do |qh|
        array = ""
        qh.board_ids.split(",").each do |board_id|
          array << Board.find(board_id.to_i).name << ","
        end unless qh.board_ids.nil?
        qh.board_ids = array[0...-1]
        array = ""
        qh.degree_ids.split(",").each do |degree_id|
          if degree_id.to_i != 0
            array << Degree.find(degree_id.to_i).name << ","
          end
        end unless qh.degree_ids.nil?
        qh.degree_ids = array[0...-1]

        array = ""
        qh.topic_ids.split(",").each do |topic_id|
          if topic_id.to_i != 0
            array << Topic.find(topic_id.to_i).name << ","
          end
        end unless qh.topic_ids.nil?
        qh.topic_ids = array[0...-1]
      end
      @courses =[]
      if (!params[:course].nil?)
        @course_id = params[:course]
        @course_linking = CourseLinking.search_on_course_column(@course_id)
        @course_linking_id = @course_linking.id
        @courses = Course.where("id = ? OR id = ? OR id = ? OR ID = ?",@course_linking.course_1, @course_linking.course_2,
                                @course_linking.course_3, @course_linking.course_4)
      elsif (!@question.course_linking_id.nil?)
        @course_linking = CourseLinking.find(@question.course_linking_id)
        @course_linking_id = @course_linking.id
        @courses = Course.where("id = ? OR id = ? OR id = ? OR ID = ?",@course_linking.course_1, @course_linking.course_2,
                                @course_linking.course_3, @course_linking.course_4)
      end
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

    puts "++++++++++++>>>>>>>>",params.inspect
    @question = Question.find_by_id(params[:id])

    # @topic = @question.topic
    # @course_id = @topic.course_id
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
    # @topics = Course.find_by_id(@course_id).topics

    #test_id = params[:test_id]
    if (!params[:course].nil?)
      @course_id = params[:course]
      @course_linking = CourseLinking.search_on_course_column(@course_id)
      @course_linking_id = @course_linking.id
      @courses = Course.where("id = ? OR id = ? OR id = ? OR ID = ?",@course_linking.course_1, @course_linking.course_2,
                              @course_linking.course_3, @course_linking.course_4)
    elsif (!@question.course_linking_id.nil?)
      @course_linking = CourseLinking.find(@question.course_linking_id)
      @course_linking_id = @course_linking.id
      @courses = Course.where("id = ? OR id = ? OR id = ? OR ID = ?",@course_linking.course_1, @course_linking.course_2,
                              @course_linking.course_3, @course_linking.course_4)
    end

  end

  ###################################################################################################################

  def add_questions

    puts "============================>>",params.inspect

    @question = Question.new

    if params[:q_id]
      @current_question = Question.find(params[:q_id])
      # @course_linking_id = @current_question.course_linking_id
      # @course_id = @current_question.topic.course_id
      @boards = []
      @degrees = []
      @current_question.board_degree_assignments.each do |bd|
        @boards << bd.board_id
        @degrees << bd.degree_id
      end
      @boards = @boards.uniq
      @degrees = @degrees.uniq
      @view = @current_question.question_type.to_s
    elsif session[:question].nil?
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

    # if @course_id.nil?
    #   redirect_to questions_path
    # else
      # @topics = Course.find_by_id(@course_id).topics

      # @boards_name = []
      # # unless @boards.nil?
      # @boards.each do |board|
      #   @boards_name << Board.find_by_id(board).name
      # end
      # # end
      # @degrees_name = []
    if (!params[:course].nil?)
      @course_id = params[:course]
      @course_linking = CourseLinking.search_on_course_column(@course_id)
      @course_linking_id = @course_linking.id
      @courses = Course.where("id = ? OR id = ? OR id = ? OR ID = ?",@course_linking.course_1, @course_linking.course_2,
                                                                      @course_linking.course_3, @course_linking.course_4)
    elsif (!@current_question.course_linking_id.nil?)
      @course_linking = CourseLinking.find(@current_question.course_linking_id)
      @course_linking_id = @course_linking.id
      @courses = Course.where("id = ? OR id = ? OR id = ? OR ID = ?",@course_linking.course_1, @course_linking.course_2,
                              @course_linking.course_3, @course_linking.course_4)
    end

      # @course_linking_id = Question.find_by_id(params[:q_id]).course_linking_id
      # puts "---------------------------->>>>>>",@course_linking_id
      # unless @degrees.nill?
      # @degrees.each do |degree|
      #   @degrees_name << Degree.find_by_id(degree).name
      # end
      # end
    # end


  end



  ###################################################################################################################


  def render_view


    test_id = params[:test_id]
    @dc_hash = Hash.new
    test = Test.find_by_id(test_id)
    @dc_hash['degree'] = test.degree_course_assignment.degree
    @dc_hash['course'] = test.degree_course_assignment.course
    @dc_hash['test'] = test
    @questions = test.questions.select { |x| x.deleted == false }
    @topics = Topic.all.select { |x| x.degree_course_assignment_id == test.degree_course_assignment_id }

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
    @topics = Topic.all.select { |x| x.degree_course_assignment_id == test.degree_course_assignment_id }

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

  def past_paper_history_param



    @past_p_h = params[:past_paper_h]
    a = params[:course_id]
    b = params[:ques_no]
    c = params[:session]
    d = params[:year]
    e = params[:varient]
    puts "---course_id----",a.inspect
    puts "---ques_no----",b.inspect
    puts "---session----",c.inspect
    puts "---year----",d.inspect
    puts "---varient----",e.inspect

  @past_paper_history = Question.joins("INNER JOIN past_paper_histories p ON questions.id = p.question_id").where("p.course_id = ?
                                                                                              and p.ques_no = ?
                                                                                              and p.session = ?
                                                                                              and p.year = ?
                                                                                              and varient = ? and deleted = false", a,b,c,d,e)


    puts "-------------->", @past_paper_history.count
    if @past_paper_history.count!=0
    respond_to do |format|
      format.json { render :json =>   result = true }

    end
    else
      respond_to do |format|
        format.json { render :json => result = false }
      end
    end
  end
  def past_paper_history_param_edit



    @past_p_h = params[:past_paper_h]
    a = params[:course_id]
    b = params[:ques_no]
    c = params[:session]
    d = params[:year]
    e = params[:varient]
    puts "---course_id----",a.inspect
    puts "---ques_no----",b.inspect
    puts "---session----",c.inspect
    puts "---year----",d.inspect
    puts "---varient----",e.inspect

    @past_paper_history = Question.joins("INNER JOIN past_paper_histories p ON questions.id = p.question_id").where("p.course_id = ?
                                                                                              and p.ques_no = ?
                                                                                              and p.session = ?
                                                                                              and p.year = ?
                                                                                              and varient = ? and deleted =false" , a,b,c,d,e)


    puts "-------------->", @past_paper_history.count
    if @past_paper_history.count!=0
      respond_to do |format|
        format.json { render :json =>   result = true }

      end
    else
      respond_to do |format|
        format.json { render :json => result = false }
      end
    end
  end
  def create


    puts "===================>>>params.inspect=",params.inspect

    @boards = params[:boards]
    @degrees = params[:degrees]

    @boards = @boards.split(" ")
    @degrees = @degrees.split(" ")


    @question = Question.new(params[:question])
    @question.varient= params[:varient]
    @question.difficulty= params[:difficulty]
    @question.statement = params[:tinymce4]
    @question.description = params[:tinymce5]

    @question.course_linking_id = params[:course_linking_id]

    #@question.topic_id = params[:topic_id]
    @question.test_id = nil
    @question.deleted = false
    @question.author = current_user.email
    if @question.save

      if current_user.is_teacher?
        @question.update_attribute(:workflow_state,'reviewed_by_proofreader')
      end

      if params[:pastPaperFlag] == '1'
        @past_paper = PastPaperHistory.new(:flag => params[:pastPaperFlag],
                                           :ques_no => params[:ques_no],
                                           :session => params[:session],
                                           :year => params[:year],
                                           :course_id => params[:course_id],
                                           :question_id => @question.id
        )
        @past_paper.save
      end

      if params[:type_ques] == 'mcq'
        ##logic for mcqs questions

        i = 1
        while (i <= params[:count_option].to_i) do
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
              :is_answer => is_answer
          )
          case option.flag
            when 1
              if option.avatar_file_name.present?
                option.avatar_file_name = (Time.now.to_i).to_s + '_' + option.avatar_file_name
                option.save
              end
            else
              if option.statement.present?
                option.save
              end
          end
          i = i + 1
        end


      elsif params[:type_ques] == 'trueFalse'
        @option = Option.new(:statement => params[:option], :question_id => @question.id, :is_answer => params[:is_answer])
        @option.save
      else

        @option = Option.new(:statement => params[:answer], :question_id => @question.id, :is_answer => 1)
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
    @question.varient= params[:varient]
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
                                           :course_id => params[:course_id],
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
                                                     :course_id => params[:course_id],
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
      while (i <= params[:count_option].to_i) do
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
            :is_answer => is_answer
        )
        case option.flag
          when 1
            if option.avatar_file_name.present?
              option.avatar_file_name = (Time.now.to_i).to_s + '_' + option.avatar_file_name
              option.save
            end
          else
            if option.statement.present?
              option.save
            end
        end
        i = i + 1
      end
    elsif params[:type_ques] == 'trueFalse'
      @question.options.last.update_attributes(:statement => params[:option], :question_id => @question.id, :is_answer => params[:is_answer])
    else
      @question.options.last.update_attributes(:statement => params[:answer], :question_id => @question.id, :is_answer => 1)
    end
    redirect_to question_path(@question)
  end

  def questions_approval
    respond_to do |format|
      format.html
      format.json { render :json => QuestionsDatatable.new(view_context,params[:teacher_self_flag]) }
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
      @questions = Question.where(:workflow_state => "reviewed_by_proofreader").search(search, page, limit)
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
    @question.deleted = true
    @question.save

    redirect_to "/questions/questions_approval"
  end

  #get methods
  def questions_exits
    puts "--------",params.inspect
    year = params["year"]
    session = params[:session]
    board_id = params[:board_id]
    degree_id = params[:degree_id]
    course_id = params[:course_id]
    past_paper_flag = params[:pre_Past]
    varient = params[:varient]
    puts "=-=-=-varient=-=-=-=",varient.inspect
    ques_no = params[:ques_no]
    bd = BoardDegreeAssignment.find_by_board_id_and_degree_id(board_id, degree_id)
    @questions = []
    if past_paper_flag.to_i == 2
      mcq = params[:mcq]
      fill = params[:fill]
      true_false = params[:true_false]
      descriptive = params[:descriptive]
      temp = Question.joins(:question_histories, :course_linking).where(" deleted ='false' and workflow_state='accepted' and varient = '' and course_linking_id = ? " , CourseLinking.search_on_course_column(course_id).id)
      puts "========",temp.inspect
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
      @questions = Question.joins("INNER JOIN past_paper_histories p ON questions.id = p.question_id").where(
          "p.course_id = ? and p.year = ? and p.session = ?
                               and deleted = 'false'
                              and workflow_state = 'accepted'" ,course_id.to_s,year.to_s,session.to_s )
      # @questions = Question.select { |q| q.deleted == false &&
      #     q.past_paper_history.present? &&
      #     q.past_paper_history.course_id == course_id.to_i  &&
      #     #q.past_paper_history.ques_no == ques_no.to_s &&
      #     q.past_paper_history.year == year.to_s &&
      #     q.past_paper_history.session == session.to_s
      #     q.varient == varient.to_s &&
      #     q.workflow_state == 'accepted' }
      puts "=--=-=-=-question select-=-=-=-=",@questions.inspect
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
      render :json => {:success => true}
    else
      render :json => {:success => false}
    end

  end

  def approve_by_teacher

    puts "==================>>>>",params.inspect
    # mnjkbjbkj

    if params[:topic_linking].present?

    topic1_id = params[:topic_linking][:topic_1].to_i
    topic2_id = params[:topic_linking][:topic_2].to_i
    topic3_id = params[:topic_linking][:topic_3].to_i
    topic4_id = params[:topic_linking][:topic_4].to_i

    topic_ids = ""+topic1_id.to_s+","+topic2_id.to_s+","+topic3_id.to_s+","+topic4_id.to_s
    end


    @question = Question.find(params[:question_id])
    insert_to_question_history_flag = true
    message = ""
    course_list = current_user.teacher_courses
    course_ids = []

    course_list.each do |course|
      course_ids << course.course_id
    end
    course_ids.uniq!



    if (current_user.is_hod? || current_user.is_admin?)
      if @question.current_state.to_s == "accepted"
        message = "Question already approved!"
        insert_to_question_history_flag = false
      else
        publish = params[:publishes]
        difficulti = params[:difficulties]
        question_data = { "topic_ids" => topic_ids, "degree_ids" => publish,
                             "difficulty_ids" => difficulti.to_s}
        @question.update_attributes(question_data)
        @question.accept!
        @question = Question.select("questions.*,topics.name as topic_name,courses.name as course_name").
            joins(:topic => :course).
            where("workflow_state IN ('reviewed_by_proofreader', 'being_reviewed', 'rejected_by_teacher') and course_id IN (?)", course_ids).first
      end

    else
      if @question.current_state.to_s == "being_reviewed" && @question.question_histories.count == 2
        @question_histories1 = @question.question_histories.first
        puts "-----QH1-----",@question_histories1.inspect

        @question_historis2 = @question.question_histories.last
        puts "-----QH2-----",@question_historis2.inspect
        degree_ids = params[:publishes]
        difficulties = params[:difficulties]

        question_verify = { "topic_ids" => topic_ids, "degree_ids" => degree_ids,
                            "difficulty_str" => difficulties.to_s }
        puts "=-------======question_verify==--==-=-=-=-=-",question_verify.inspect

        acceptQuestionFlag1 = false
        if (@question_histories1.degree_ids == @question_historis2.degree_ids ||
            @question_histories1.degree_ids == question_verify["degree_ids"] ||
            question_verify["degree_ids"] == @question_historis2.degree_ids)

          if
          @question_histories1.degree_ids == @question_historis2.degree_ids
            degree_ids_value = @question_histories1.degree_ids
          elsif
          @question_historis2.degree_ids == question_verify["degree_ids"]
            degree_ids_value = @question_historis2.degree_ids
          else
            @question_histories1 == question_verify["degree_ids"]
            degree_ids_value = question_verify["degree_ids"]
          end
          acceptQuestionFlag1 = true
        end
        acceptQuestionFlag2 = false
        if (@question_histories1.topic_ids == @question_historis2.topic_ids ||
            @question_histories1.topic_ids == question_verify["topic_ids"] ||
            question_verify["topic_ids"] == @question_historis2.topic_ids)

          if
            @question_histories1.topic_ids == @question_historis2.topic_ids
            topic_ids_value = @question_histories1.topic_ids
          elsif
          @question_historis2.topic_ids == question_verify["topic_ids"]
            topic_ids_value = @question_historis2.topic_ids
          else
            @question_histories1.topic_ids == question_verify["topic_ids"]
            topic_ids_value = question_verify["topic_ids"]
          end
          acceptQuestionFlag2 = true
        end
        acceptQuestionFlag3 = false

        if (@question_histories1.difficulty_str == @question_historis2.difficulty_str ||
            @question_histories1.difficulty_str == question_verify["difficulty_str"] ||
            question_verify["difficulty_str"] == @question_historis2.difficulty_str)

          if
          @question_histories1.difficulty_str == @question_historis2.difficulty_str
            difficulty_ids_value = @question_histories1.difficulty_str
          elsif
          @question_historis2.difficulty_str == question_verify["difficulty_str"]
            difficulty_ids_value = @question_historis2.difficulty_str
          else
            @question_histories1.difficulty_str == question_verify["difficulty_str"]
            difficulty_ids_value = question_verify["difficulty_str"]
          end
          acceptQuestionFlag3 = true
        end
        if acceptQuestionFlag1 && acceptQuestionFlag2 && acceptQuestionFlag3
          question_data1 = { "topic_ids" => topic_ids_value, "degree_ids" => degree_ids_value,
                            "difficulty_ids" => difficulty_ids_value.to_s}
          @question.update_attributes(question_data1)
          @question.accept!
        else
          @question.submitToHOD!
        end

      elsif @question.current_state.to_s == "reviewed_by_proofreader"
        @question.submit!
      elsif @question.current_state.to_s == "accepted" || @question.question_histories.count == 3
        message = "Question already approved!"
        insert_to_question_history_flag = false
      end
    end


    if insert_to_question_history_flag
      # board_ids = params[:boards]
      degree_ids = params[:degree]
      topic_id = params[:topic]
      difficulty = params[:difficulty]
      difficulties = params[:difficulties]
      pub = params[:publishes]
      # @question = params[:question_id]
      board_id_array = ""
      degree_id_array = ""

      degree_ids.each do |degree_id|
        degree_id_array << degree_id.to_s << ","
      end unless degree_ids.nil?
      puts "%%% ------>>>>>> degree id checking %%%",degree_id_array.inspect
      question_history = {"board_ids" => board_id_array, "degree_ids" => pub, "topic_id" => topic_id, "user_id" => current_user.id, "question_id" => params[:question_id],
                          "is_approved" => 1, "difficulty_str" => difficulties.to_s}

      # question_history = {"degree_ids" => degree_id_array, "topic_id" => topic_id,
      #                     "difficulty" => difficulty.first.to_i, "user_id" => current_user.id, "question_id" => @question.id,
      #                     "is_approved" => 1}

      @question_history = QuestionHistory.new(question_history)
      @question_history.topic_ids = topic_ids.to_s

      @question_history.save
      # if @question.current_state == "accepted"
      #   publish_question(@question)
      # end
    end


    if current_user.is_teacher?
      @question = Question.select("questions.*").
          joins(:course_linking).
          where("author != ? AND (course_1  IN (?) OR course_2  IN (?) OR course_3  IN (?) OR course_4  IN (?)) and workflow_state IN ('reviewed_by_proofreader', 'being_reviewed') and
                        questions.id NOT IN (SELECT question_id as id FROM question_histories WHERE user_id = ?) and deleted = 'FALSE'",current_user.email, course_ids, course_ids, course_ids, course_ids, current_user.id).first
    end

    if @question.present?
      render :json => {:success => true, :question_id => @question.id, :message => message}
    else
      render :json => {:success => true, :question_id => ""}
    end
  end


  def approve_question

    @question = Question.find(params[:ques_id])
    if @question && (@question.current_state.to_s == "new")
      ##### check if workflow path is enable or disable
      ### fetch all degrees of this course
      @degrees = []
      @question.board_degree_assignments.each do |bd|
        @degrees << bd.degree.id
      end
      @degrees.uniq!

      ##### fetch the course
      # @course = @question.topic.course.id
      @course = @question.course_linking_id
      puts "===================>>>>>",@course.inspect
      ####### check if any entry is present in workflow with a false
      flag_path = true
      WorkflowPath.all.each do |workflow_path|
        @course_ids = CourseLinking.search_on_course_column(workflow_path.course_id)
        if @course_ids.present?
        course_linking_id =  CourseLinking.search_on_course_column(workflow_path.course_id).id
        end
        if course_linking_id == @course
          flag_path = false if workflow_path.is_complete == false
        end
      end
      if flag_path == true
        @question.submit!
      else
        ########## submit to hod for submission???????????
        @question.accept!
      end


      if params[:from].present? && params[:from] == "view"
        if current_user.email == "proofreader1@els.com"
          @question = Question.where("workflow_state = 'new' or workflow_state is null  and deleted = 'FALSE'").first
        else
          @question = Question.where("(workflow_state = 'new' or workflow_state is null) and author = ? and deleted = 'FALSE'", current_user.email).first
        end
        # @question = Question.where("workflow_state = 'new' or workflow_state is null").first
        if @question
          redirect_to question_path(@question)
        else
          redirect_to questions_approval_questions_path
        end
      else
        render :json => {:success => true}
      end
    end
  end

  def reject_question


    # puts "=====================><><><><reject_question",params.inspect

    @question = Question.find(params[:question][:id])
    message = ""
    if current_user.is_teacher?
      insert_to_question_history_flag = true
      if @question.current_state.to_s == "rejected_by_teacher" || @question.current_state.to_s == "accepted"
        insert_to_question_history_flag = false
        message = "Question already updated!"
      end
      if insert_to_question_history_flag
        board_ids = params[:boards]
        degree_ids = params[:degree]
        topic_id = params[:topic]
        difficulty = params[:difficulty]
        board_id_array = ""
        degree_id_array = ""
        board_ids.each do |board_id|
          board_id_array << board_id.to_s << ","
        end unless board_ids.nil?
        degree_ids.each do |degree_id|
          degree_id_array << degree_id.to_s << ","
        end unless degree_ids.nil?
        question_history = {"board_ids" => board_id_array, "degree_ids" => degree_id_array, "topic_id" => topic_id,
                            "difficulty" => difficulty.to_i, "user_id" => current_user.id, "question_id" => @question.id,
                            "is_approved" => 0}

        @question_history = QuestionHistory.new(question_history)
        @question_history.save
        @question.update_attributes(:comments => params[:comments].to_s)
        @question.reject!

      end
      course_list = current_user.teacher_courses
      course_ids = []
      course_list.each do |course|
        course_ids << course.course_id
      end
      @question = Question.select("questions.*,topics.name as topic_name,courses.name as course_name").
          joins(:topic => :course).
          where("author != ? AND course_id IN (?) and workflow_state IN ('reviewed_by_proofreader', 'being_reviewed') and
                      questions.id NOT IN (SELECT question_id as id FROM question_histories WHERE user_id = ?)  and deleted = 'FALSE'",current_user.email, course_ids, current_user.id).first
    elsif current_user.is_proofreader?
      #if current_user.email == "proofreader1@els.com"
        @question = Question.where("workflow_state = 'new' or workflow_state is null and deleted = 'FALSE'").first
        @question.update_attributes(:comments => params[:comments].to_s)
        @question.reject!
        # redirect_to questions_approval_questions_path
      #else
       # @question = Question.where(:author => current_user.email).first
      #end
    end
    if @question.present?
      # redirect_to questions_path
      render :json => {:success => true, :question_id => @question.id, :message => message}
    else
      render :json => {:success => true, :question_id => "", :message => message}
    end
  end

  def reject_by_teacher
    @question = Question.find(params[:question_id])
    if current_user.is_hod?
      @question.rejected_by_hod!
    else
      @question.update_attributes(:comments => params[:comments].to_s)
      @question.reject!
    end
    render :json => {:success => true}
  end

  def remove_option
    question = Question.find(params[:question_id])
    if question.options.count == params[:count].to_i && question.options.count > 4
      question.options[question.options.count-1].delete
    end
    render :json => {:success => true}
  end

  def questions_detail
    @ques_detail_hash = {}
    Degree.all.each do |degree|
      ####  fetch all board_degrees of this degree ####
      degree.board_degree_assignments.each do |bd|
        #### fetch all courses
        bd.courses.each do |course|
          type_size = {
              1 => 0,
              2 => 0,
              3 => 0,
              4 => 0,
          }
          course.topics.each do |x|
            type_size[1] += x.questions.select{|question| question.question_type == 1}.size
            type_size[2] += x.questions.select{|question| question.question_type == 2}.size
            type_size[3] += x.questions.select{|question| question.question_type == 3}.size
            type_size[4] += x.questions.select{|question| question.question_type == 4}.size
          end

          @ques_detail_hash["#{degree.name}_#{course.name}_#{course.id}"] = type_size
        end
      end
    end
  end

  def get_question_detail
    @hash_detail = {}
    @hash_detail["Total"] = 0

    topics = Course.find(params[:course_id]).topics
    topics.each do |topic|
      count = Question.where("topic_id = ? AND question_type = ?  and deleted = 'FALSE'",topic.id,params[:question_type]).count
      @hash_detail["Total"] += count
      @hash_detail["#{topic.name}"] = count
    end
    render partial: 'ques_detail'
  end

  def get_course_linking
    @course_linking = CourseLinking.search_on_course_column(params[:course_id])
    render :partial => 'course_linking_tbl'
  end
  def get_topic_course_link
    respond_to do |format|
      # @course_linking = CourseLinking.search_on_course_column(params[:course_id])
      @course_linking = CourseLinking.find(params[:course_linking_id])
      if @course_linking.nil?
        @flag = false
      else
        arr = []
        TopicLinking.all.each do |topic|
          arr << topic.topic_1 unless topic.topic_1.nil?
          arr << topic.topic_2 unless topic.topic_2.nil?
          arr << topic.topic_3 unless topic.topic_3.nil?
          arr << topic.topic_4 unless topic.topic_4.nil?
        end
        arr.uniq!
        if arr.blank?
          @topics_1 = Topic.where("course_id = ?",@course_linking.course_1)
          @topics_2 = Topic.where("course_id = ?",@course_linking.course_2)
          @topics_3 = Topic.where("course_id = ?",@course_linking.course_3)
          @topics_4 = Topic.where("course_id = ?",@course_linking.course_4)
        else
          @topics_1 = Topic.where("course_id = ?",@course_linking.course_1)
          @topics_2 = Topic.where("course_id = ?",@course_linking.course_2)
          @topics_3 = Topic.where("course_id = ?",@course_linking.course_3)
          @topics_4 = Topic.where("course_id = ?",@course_linking.course_4)
        end

        @flag = true
      end
      format.html { render :partial => "get_topic_course_link" }
    end
  end



  def get_all_topics_from_topic_linking
    respond_to do |format|
      @question = params[:question_id].to_i
      @course_linking_id = Question.find(@question).course_linking_id
      @course_linking = CourseLinking.find(@course_linking_id)
      @topic_linking_array = TopicLinking.where("topic_1 = ? OR topic_2 = ? OR topic_3 = ? OR topic_4 = ?",params[:topic_id],params[:topic_id],params[:topic_id],params[:topic_id])
      if @course_linking.nil?
        @flag = false
      else
        arr = []
        @topic_linking_array.each do |topic|
          arr << topic.topic_1 unless topic.topic_1.nil?
          arr << topic.topic_2 unless topic.topic_2.nil?
          arr << topic.topic_3 unless topic.topic_3.nil?
          arr << topic.topic_4 unless topic.topic_4.nil?
        end
        arr.uniq!
        if arr.blank?
          @topics_1 = Topic.where("course_id = ?",@course_linking.course_1)
          @topics_2 = Topic.where("course_id = ?",@course_linking.course_2)
          @topics_3 = Topic.where("course_id = ?",@course_linking.course_3)
          @topics_4 = Topic.where("course_id = ?",@course_linking.course_4)
        else
          @topics_1 = Topic.where("course_id = ? AND id IN (#{arr.join(",")})",@course_linking.course_1)
          @topics_2 = Topic.where("course_id = ? AND id IN (#{arr.join(",")})",@course_linking.course_2)
          @topics_3 = Topic.where("course_id = ?",@course_linking.course_3)
          @topics_4 = Topic.where("course_id = ? AND id IN (#{arr.join(",")})",@course_linking.course_4)
        end

        @flag = true
      end
      format.html { render :partial => "get_all_topics_from_topic_linking" }
    end
  end

  ###################################################### Questions Rejected by proofreader ######################################################

  def rejected_questions
    @author = User.find_by_id(current_user.role).email
    @rejected_questions = Question.where("author = ? AND workflow_state = 'rejected'",current_user.email)
  end

  ######################################################  ######################################################

  private
  def publish_question(question)
    if current_user.is_hod?

    elsif current_user.is_teacher?

    end
    if
    question
    end

  end

  def set_question
    @question = Question.find(params[:id])
  end
end
