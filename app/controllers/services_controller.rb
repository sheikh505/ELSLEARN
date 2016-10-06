class ServicesController < ApplicationController
  respond_to :json
  skip_before_filter :authenticate_user!
  before_filter :check_session, :except => [:sign_in, :verify_answers, :get_lookup_data, :get_courses_by_teacher,
                                            :get_student_quiz_list, :get_questions, :get_quiz_list, :create_quiz, :quiz, :get_els_questions]

  def sign_in
    user = User.find_by_email(params[:user][:email])
    if user.present? && user.valid_password?(params[:user][:password])
        user.update_attributes(:device_token => params[:user][:token])
        user.role = user.roles.first.name.downcase
        # data = {:auth_token => user.auth_token}
        render :json => {:success => "true", :user => user, :message => "User signed In"}
    else
      render :json => {:success => "false", :message => "Invalid Email Or Password."}
    end
  end

  def get_lookup_data
    boards = Board.all
    degrees = Degree.joins(:board_degree_assignments).select("degrees.id, degrees.name, board_degree_assignments.board_id")
    courses = Course.joins(degree_course_assignments: :board_degree_assignment).select("courses.id, courses.name, board_id, degree_id")
    question_ids = []
    past_papers = PastPaperHistory.all
    sessions = []
    past_papers.uniq{|x| x.session}.each do |uniqueItems|
      sessions << uniqueItems.session
    end
    years = []
    past_papers.uniq{|x| x.year}.each do |uniqueItems|
      years << uniqueItems.year
    end

    past_papers.each do |paper|
      question_ids << paper.question_id
    end
    all_questions_with_fetched_ids = Question.find_all_by_id(question_ids)
    variants = []
    all_questions_with_fetched_ids.each do |question_varient|
      variants << question_varient.varient
    end
    variants.compact!
    variants = variants.reject { |c| c.empty? }
    variants.uniq!
    # years = Course.joins(degree_course_assignments: :board_degree_assignment).select("courses.id, courses.name, board_id, degree_id")
    # sessions = Course.joins(degree_course_assignments: :board_degree_assignment).select("courses.id, courses.name, board_id, degree_id")
    # variants = Course.joins(degree_course_assignments: :board_degree_assignment).select("courses.id, courses.name, board_id, degree_id")
    render :json => {:success => "true", :boards => boards, :degrees => degrees, :courses => courses, :sessions => sessions,
                                         :variants => variants, :years => years }
  end

  def get_all_boards
    boards = Board.all
    if boards.present?
      render :json => {:success => "true", :boards => boards}
    else
      render :json => {:success => "false", :message => "Not boards present."}
    end
  end

  def get_all_degrees
    degrees = Degree.all
    if boards.present?
      render :json => {:success => "true", :degrees => degrees}
    else
      render :json => {:success => "false", :message => "Not degrees present."}
    end
  end

  #get methods
  def is_questions_exists
    year = params["year"]
    session = params[:session]
    board_id = params[:board_id]
    degree_id = params[:degree_id]
    course_id = params[:course_id]
    past_paper_flag = params[:pre_Past]
    varient = params[:varient]
    selected_topic_ids = params[:selected_topic_ids].split(",")
    puts "--------selected topics------",selected_topic_ids.inspect
    puts "=-=-=-varient=-=-=-=",varient.inspect
    ques_no = params[:ques_no]
    bd = BoardDegreeAssignment.find_by_board_id_and_degree_id(board_id, degree_id)
    @questions = []
    if past_paper_flag.to_i == 2
      mcq = params[:mcq]
      fill = params[:fill]
      true_false = params[:true_false]
      descriptive = params[:descriptive]
      # temp = Question.joins(:question_histories, :course_linking).where(" deleted ='false' and workflow_state='accepted' and varient = '' and course_linking_id = ? " , CourseLinking.search_on_course_column(course_id).id)
      question_select = Question.includes(:past_paper_history).where("deleted = 'false' and workflow_state ='accepted' ")
      # question_select = Question.where(" deleted = 'false' and workflow_state = 'accepted' and varient = '' ")

      temp = question_select.select{|x|  x.topic_ids.present? &&
          (selected_topic_ids.include?(x.topic_ids.split(",")[0]) ||
              selected_topic_ids.include?(x.topic_ids.split(",")[1]) ||
              selected_topic_ids.include?(x.topic_ids.split(",")[2]) ||
              selected_topic_ids.include?(x.topic_ids.split(",")[3]))  &&
          x.degree_ids.present? && (degree_id.include?(x.degree_ids.split(",")[0])||
          degree_id.include?(x.degree_ids.split(",")[1]) ||
          degree_id.include?(x.degree_ids.split(",")[2]) ||
          degree_id.include?(x.degree_ids.split(",")[3]) ) }
      puts "====Question_without_pastPaperHistory====",temp.inspect
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

      questions_data = Question.joins("INNER JOIN past_paper_histories p ON questions.id = p.question_id").where(
          "p.course_id = ? and p.year = ? and p.session = ?
                               and deleted = 'false'
                              and workflow_state = 'accepted'" ,course_id.to_s,year.to_s,session.to_s )
      @questions = questions_data.select{|x|  x.topic_ids.present? &&
          (selected_topic_ids.include?(x.topic_ids.split(",")[0]) ||
              selected_topic_ids.include?(x.topic_ids.split(",")[1]) ||
              selected_topic_ids.include?(x.topic_ids.split(",")[2]) ||
              selected_topic_ids.include?(x.topic_ids.split(",")[3])) &&
          x.degree_ids.present? && (degree_id.include?(x.degree_ids.split(",")[0])||
          degree_id.include?(x.degree_ids.split(",")[1]) ||
          degree_id.include?(x.degree_ids.split(",")[2]) ||
          degree_id.include?(x.degree_ids.split(",")[3]) )}
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

  def is_test_exists
    test_code = params["test_code"]
    quiz = Quiz.find_by_test_code(test_code)
    if (quiz.present? && quiz.question_ids.present? )
      render :json => {:success => true}
    else
      render :json => {:success => false}
    end
  end

  def get_questions_by_test_code
    test_code =  params[:test_code]
    quiz = Quiz.find_by_test_code(test_code)
    if quiz.present? && quiz.question_ids.present?
      question_ids = quiz.question_ids
      questions = Question.find(question_ids.split(','))

      @questionlist = questions.map do |u|
        { :id=> u.id, :statement => u.statement, :type => u.question_type,
          :options =>  u.options.map do |o|
            {:id => o.id, :question_id => o.question_id, :flag => o.flag, :image_url => o.avatar.url(:medium), :statement => o.statement.present? ? o.statement : "NNNN", :is_answer => o.is_answer}
          end
        }
      end

      render :json => {:success => true, :questions => @questionlist}
    else
      render :json => {:success => false}
    end
  end

  def fetch_questions
    puts "=============================>", params.inspect
    die
    year = params[:year]
    session = params[:session]
    board_id = params[:board_id]
    degree_id = params[:degree_id]
    course_id = params[:course_id]
    past_paper_flag = params[:past_paper_flag]
    varient = params[:varient]
    selected_topic_ids = params[:selected_topic_ids].split(",")
    puts "--------selected topics------",selected_topic_ids.inspect
    puts "=-=-=-varient=-=-=-=",varient.inspect
    ques_no = params[:ques_no]
    bd = BoardDegreeAssignment.find_by_board_id_and_degree_id(board_id, degree_id)
    @questions = []
    if past_paper_flag.to_i == 2
      mcq = params[:mcq]
      fill = params[:fill]
      true_false = params[:true_false]
      descriptive = params[:descriptive]
      # temp = Question.joins(:question_histories, :course_linking).where(" deleted ='false' and workflow_state='accepted' and varient = '' and course_linking_id = ? " , CourseLinking.search_on_course_column(course_id).id)
      question_select = Question.includes(:past_paper_history).where("deleted = 'false' and workflow_state ='accepted' ")
      # question_select = Question.where(" deleted = 'false' and workflow_state = 'accepted' and varient = '' ")

      temp = question_select.select{|x|  x.topic_ids.present? &&
          (selected_topic_ids.include?(x.topic_ids.split(",")[0]) ||
              selected_topic_ids.include?(x.topic_ids.split(",")[1]) ||
              selected_topic_ids.include?(x.topic_ids.split(",")[2]) ||
              selected_topic_ids.include?(x.topic_ids.split(",")[3]))  &&
          x.degree_ids.present? && (degree_id.include?(x.degree_ids.split(",")[0])||
          degree_id.include?(x.degree_ids.split(",")[1]) ||
          degree_id.include?(x.degree_ids.split(",")[2]) ||
          degree_id.include?(x.degree_ids.split(",")[3]) ) }
      puts "====Question_without_pastPaperHistory====",temp.inspect
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

      questions_data = Question.joins("INNER JOIN past_paper_histories p ON questions.id = p.question_id").where(
          "p.course_id = ? and p.year = ? and p.session = ?
                               and deleted = 'false'
                              and workflow_state = 'accepted'" ,course_id.to_s,year.to_s,session.to_s )
      @questions = questions_data.select{|x|  x.topic_ids.present? &&
          (selected_topic_ids.include?(x.topic_ids.split(",")[0]) ||
              selected_topic_ids.include?(x.topic_ids.split(",")[1]) ||
              selected_topic_ids.include?(x.topic_ids.split(",")[2]) ||
              selected_topic_ids.include?(x.topic_ids.split(",")[3])) &&
          x.degree_ids.present? && (degree_id.include?(x.degree_ids.split(",")[0])||
          degree_id.include?(x.degree_ids.split(",")[1]) ||
          degree_id.include?(x.degree_ids.split(",")[2]) ||
          degree_id.include?(x.degree_ids.split(",")[3]) )}
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
      @questionlist = @questions.map do |u|
        { :id=> u.id, :statement => u.statement, :type => u.question_type,
          :options =>  u.options.map do |o|
            {:id => o.id, :question_id => o.question_id, :flag => o.flag, :image_url => o.avatar.url(:medium), :statement => o.statement.present? ? o.statement : "", :is_answer => o.is_answer}
          end
        }
      end

      render :json => {:success => true, :questions => @questionlist}
    else
      render :json => {:success => false}
    end
  end

  def get_options_by_question_id
    question_id =  params[:question_id]
    question = Question.find(question_id)
    if question.present?
      options = question.options
      render :json => {:success => true, :options => options}
    else
      render :json => {:success => false}
    end
  end

  def get_student_quiz_list
    @student = User.find_by_email(params[:email])
    @quizzes = UserTestHistory.where(:user_id => @student.id)
    @quizzes = @quizzes.map{|quiz|
      {
          :test_code => quiz.code,
          :obtained_marks => quiz.score,
          :total_marks => quiz.total,
          :created_at => quiz.created_at
      }
    }
    if @quizzes
      render :json => {:success => true, :quizzes => @quizzes}
    else
      render :json => {:success => false}
    end
  end

  def get_quiz_list
    @quizzes = Quiz.where(:user_id => User.find_by_email(params[:email]).id)
    if @quizzes.size == 0
      render :json => {:success => false}
    else
      @quizzes = @quizzes.map{|a|
        {
          :quiz_id => a.id,
          :name => a.name,
          :course_id => a.course_id,
          :created_at => a.created_at,
          :question_ids => a.question_ids,
          :test_code => a.test_code,
          :user_id => a.user_id,
          :ques_count => a.question_ids.split(",").length
        }
      }
      render :json => {:success => true, :quiz_list => @quizzes}
    end
  end

  def verify_answers
    puts "===========================>", params.inspect
    @score = 0

    array = params[:array].split(",")
    @total = array.length*5
    array.each do |ques|
      @question = Question.find(ques.split(":")[0])
      if @question.question_type == 1
        if ques.split(":")[1]
          if ques.split(":")[1] != 'ref_0' && ques.split(":")[1] != 'ref_1' && ques.split(":")[1] != 'ref_2' && ques.split(":")[1] != 'ref_3'
            @option = Option.find(ques.split(":")[1])
            if @option.is_answer == 1
              @score += 5
            end
          end
        end
      elsif @question.question_type == 4
        @option = @question.options.first
        if ques.split(":")[1]
          if @option.statement == ques.split(":")[1]
            @score += 5
          end
        end
      elsif @question.question_type == 3
        @options = @question.options.last.statement.split("/")
        if ques.split(":")[1]
          @options.each do |opt|
            if opt == ques.split(":")[1]
              @score += 5
              break
            end
          end
        end
      end
    end
    render :json => {:success => true, :result => @score, :total => @total}
    # answers = params[:answer]
    # answers.each do |answer|
    #   questionId = answer[:questionId]
    #   questionType = answer[:questionType]
    #   optionId = answer[:optionId]
    #   answer = answer[:answer]
    #   trueFalse = answer[:trueFalse]
    #   case (questionType)
    #     when 1
    #       puts "=================>", questionType.inspect
    #     else
    #       puts "=================>else", questionType.inspect
    #   end
    # end
    # questionId;
    # public int questionType;
    # public int optionId;
    # public String answer;
    # public boolean trueFalse;
  end

  def get_courses_by_teacher
    @courses = User.find(params[:id]).courses
    render :json => {:success => true, :courses => @courses}
  end

  def get_questions
    offset = params[:offset]
    if params[:limit]
      limit = params[:limit]
      course_id = params[:course_id]
      email = params[:email]
      @questions = Question.select("questions.*").
          joins(:course_linking).
          where("(course_1  IN (?) OR course_2  IN (?) OR course_3  IN (?) OR course_4  IN (?)) and author != ? and workflow_state = 'accepted'", course_id, course_id, course_id, course_id, email).limit(limit).offset(offset)
      @count = Question.select("questions.*").
          joins(:course_linking).
          where("(course_1  IN (?) OR course_2  IN (?) OR course_3  IN (?) OR course_4  IN (?)) and author != ? and workflow_state = 'accepted'", course_id, course_id, course_id, course_id, email).length
      if @questions.size == 0
        render :json => {:success => false}
      else
        render :json => {:success => true,:questions => @questions, :count => @count}
      end
    else
      course_id = params[:course_id]
      email = params[:email]
      @questions = Question.select("questions.*").
          joins(:course_linking).
          where("(course_1  IN (?) OR course_2  IN (?) OR course_3  IN (?) OR course_4  IN (?)) and author != ? and workflow_state = 'accepted'", course_id, course_id, course_id, course_id, email).limit(100).offset(offset)
      @count = Question.select("questions.*").
          joins(:course_linking).
          where("(course_1  IN (?) OR course_2  IN (?) OR course_3  IN (?) OR course_4  IN (?)) and author != ? and workflow_state = 'accepted'", course_id, course_id, course_id, course_id, email).length
      if @questions.size == 0
        render :json => {:success => false}.to_json
      else
        render :json => {:success => true,:questions => @questions, :count => @count}
      end
    end
  end

  def get_els_questions
    offset = params[:offset]
    if params[:limit]
      limit = params[:limit]
      @course_id = params[:course_id]
      @questions = Question.select("questions.*").
          joins(:course_linking).
          where("(course_1  IN (?) OR course_2  IN (?) OR course_3  IN (?) OR course_4  IN (?)) and workflow_state = 'accepted' and question_type in (?)",
                @course_id, @course_id, @course_id, @course_id,params[:ques_types].split(",")).limit(limit).offset(offset)
      @count = Question.select("questions.*").
          joins(:course_linking).
          where("(course_1  IN (?) OR course_2  IN (?) OR course_3  IN (?) OR course_4  IN (?)) and workflow_state = 'accepted' and question_type in (?)",
                @course_id, @course_id, @course_id, @course_id,params[:ques_types].split(",")).length
      @questions.shuffle!
      if @questions.size == 0
        render :json => {:success => false}.to_json
      else
        render :json => {:success => true,:questions => @questions, :count => @count}
      end
    else
      @course_id = params[:course_id]
      @questions = Question.select("questions.*").
          joins(:course_linking).
          where("(course_1  IN (?) OR course_2  IN (?) OR course_3  IN (?) OR course_4  IN (?)) and workflow_state = 'accepted' and question_type in (?)",
                @course_id, @course_id, @course_id, @course_id,params[:ques_types].split(",")).limit(100).offset(offset)
      @count = Question.select("questions.*").
          joins(:course_linking).
          where("(course_1  IN (?) OR course_2  IN (?) OR course_3  IN (?) OR course_4  IN (?)) and workflow_state = 'accepted' and question_type in (?)",
                @course_id, @course_id, @course_id, @course_id,params[:ques_types].split(",")).length
      @questions.shuffle!
      if @questions.size == 0
        render :json => {:success => false}.to_json
      else
        render :json => {:success => true,:questions => @questions, :count => @count}
      end
    end
  end

  def create_quiz
    @quiz = Quiz.new
    @quiz.name = params[:name] if params[:name]
    @quiz.test_code = params[:test_code] if params[:test_code]
    @quiz.user_id = User.find_by_email(params[:email]).id if params[:email]
    @quiz.question_ids = params[:question_ids] if params[:question_ids]
    @quiz.course_id = params[:course_id] if params[:course_id]
    if @quiz.save
      render :json => {:success => true, :message => "Quiz successfully created!"}
    else
      @messages = @quiz.errors.full_messages
      render :json => {:success => false, :message => @messages}
    end
  end

  def quiz
    if params[:user_test_history_id].present? || @user_test_history_id.present?
      if params[:user_test_history_id].present?
        @user_test_history_id = params[:user_test_history_id]
      end


      user_test_history = UserTestHistory.find(@user_test_history_id)
      @board_id = user_test_history[:board_id]
      @degree_id = user_test_history[:degree_id]
      @course_id = user_test_history[:course_id]
      deg_id = @degree_id.to_s
      selected_topic_ids = user_test_history[:topic_ids]
      puts "$$$$$$$$$$$$",selected_topic_ids.inspect
      puts "==========---------====",@course_id.inspect
      @mcq = user_test_history[:mcq]
      @fill = user_test_history[:fill]
      @true_false = user_test_history[:truefalse]
      @descriptive = user_test_history[:descriptive]
      @past_paper_flag = user_test_history[:pastpaperflag]
      puts "-=-=-=-=-=-=-=----====<><>>>>>",@past_paper_flag.inspect
      @year = user_test_history[:year]
      @session = user_test_history[:session]
      bd = BoardDegreeAssignment.find_by_board_id_and_degree_id(@board_id,@degree_id)
      @questions = []
      @course = Course.find(@course_id).name
      if @past_paper_flag.to_i == 2
        question_select = Question.includes(:past_paper_history).where("deleted = 'false' and workflow_state ='accepted' ")
        # question_select = Question.where(" deleted = 'false' and workflow_state = 'accepted' and varient = '' ")
        temp = question_select.select{|x|  x.topic_ids.present? &&
            (selected_topic_ids.include?(x.topic_ids.split(",")[0]) ||
                selected_topic_ids.include?(x.topic_ids.split(",")[1]) ||
                selected_topic_ids.include?(x.topic_ids.split(",")[2]) ||
                selected_topic_ids.include?(x.topic_ids.split(",")[3]))  &&
            x.degree_ids.present? && (deg_id.include?(x.degree_ids.split(",")[0])||
            deg_id.include?(x.degree_ids.split(",")[1]) ||
            deg_id.include?(x.degree_ids.split(",")[2]) ||
            deg_id.include?(x.degree_ids.split(",")[3]) ) }
        list = temp
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
      elsif @past_paper_flag.to_i == 1
        @questions_data = Question.joins("INNER JOIN past_paper_histories p ON questions.id = p.question_id").where(
            "p.course_id = ? and p.year = ? and p.session = ?
                               and deleted = 'false'
                              and workflow_state = 'accepted'" ,@course_id.to_s,@year.to_s,@session.to_s )
        puts "&&&&&&&&&&&",@questions_data.inspect
        list = @questions_data.select{|x|  x.topic_ids.present? &&
            (selected_topic_ids.include?(x.topic_ids.split(",")[0]) ||
                selected_topic_ids.include?(x.topic_ids.split(",")[1]) ||
                selected_topic_ids.include?(x.topic_ids.split(",")[2]) ||
                selected_topic_ids.include?(x.topic_ids.split(",")[3])) &&
            x.degree_ids.present? && (deg_id.include?(x.degree_ids.split(",")[0])||
            deg_id.include?(x.degree_ids.split(",")[1]) ||
            deg_id.include?(x.degree_ids.split(",")[2]) ||
            deg_id.include?(x.degree_ids.split(",")[3]) )}
        puts "^^^^^^^^%%%%%%",list.inspect
        @questions = list.shuffle
      end
    elsif params[:test_code].present? || params[:test_code_login].present? || params[:test_code_registration].present?
      if params[:test_code].present?
        test_code =  params[:test_code]
      elsif params[:test_code_login].present?
        test_code = params[:test_code_login]
      elsif params[:test_code_registration].present?
        test_code =  params[:test_code_registration]
      end
      quiz = Quiz.find_by_test_code(test_code)
      if quiz.present?
        question_ids = quiz.question_ids
        @questions = Question.find(question_ids.split(','))
      end
    end

    @user = current_user

    if @questions.present?
      puts "%%%%%%%%%%% if question present ? %%%%%%%",@questions.inspect
      @size = @questions.length
      @index = 0
      render :json => {:success => true,:questions => @questions, :size => @size, :index => @index}
    else
      render :json => {:success => false}
    end
  end

  def get_all_degrees
    degrees = Degree.all
    if boards.present?
      render :json => {:success => "true", :degrees => degrees}
    else
      render :json => {:success => "false", :message => "Not degrees present."}
    end
  end

  private
  def check_session
    if params[:auth_token].present?
      @user = User.find_by_device_token(params[:auth_token])
      render :json => {:success => false, :errors => "authentication failed"} unless @user.present?
    else
      render :json => {:success => false, :errors => "authentication failed"}
    end
  end

end
