class ServicesController < ApplicationController
  respond_to :json
  skip_before_filter :authenticate_user!
  before_filter :check_session, :except => [:sign_in, :verify_answers, :get_lookup_data, :get_courses_by_teacher,
                                            :get_topics,:verify_answers_web, :get_student_quiz_list, :live_score_details, :get_live_score_list, :get_questions, :get_quiz_list, :create_quiz, :quiz, :get_els_questions]

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

  def get_topics
    @topics = Topic.where(:course_id => params[:course_id]).order(:created_at)
    if @topics.present?
      render :json => {:success => true, :topics => @topics}
    else
      render :json => {:success => false}
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
    years.sort!
    years.reverse!

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
    variants.sort!
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
    @time_allowed = quiz.time_allowed
    user = User.find_by_email(params[:email])
    user_test_history = {:quiz_name => quiz.name,
                         :code => params[:test_code],
                         :user_id=> user.id, :is_live => true}
    user_history = UserTestHistory.new(user_test_history)
    user_history.save
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

      render :json => {:success => true, :user_test_history_id => user_history.id, :questions => @questionlist, :time_allowed => @time_allowed}
    else
      render :json => {:success => false}
    end
  end

  def live_score_details
    tests = UserTestHistory.where(:code => params[:test_code])
    user_ids = tests.uniq.pluck(:user_id)
    users = User.where('id IN (?)', user_ids)

    students = users.map do |user|
      {
          :student_email => user.email,
          :obtained_marks => user.user_test_histories.last.score,
          :total_marks => user.user_test_histories.last.total,
          :live => user.user_test_histories.last.is_live
      }
    end
    if students.present?
      render :json => {:success => true, :students => students}
    else
      render :json => {:success => false}
    end
  end

  def fetch_questions
    puts "=============================>", params.inspect
    year = params[:year]
    session = params[:session]
    board_id = params[:board_id]
    degree_id = params[:degree_id]
    course_id = params[:course_id]
    past_paper_flag = params[:past_paper_flag]
    varient = params[:varient]
    # puts "--------selected topics------",selected_topic_ids.inspect
    puts "=-=-=-varient=-=-=-=",varient.inspect
    ques_no = params[:ques_no]
    bd = BoardDegreeAssignment.find_by_board_id_and_degree_id(board_id, degree_id)
    user = User.find_by_email(params[:email])
    @questions = []
    if past_paper_flag.to_i == 2


      selected_topic_ids = params[:selected_topic_ids].split(",")

      mcq = params[:mcq]
      fill = params[:fill]
      true_false = params[:true_false]
      descriptive = params[:descriptive]

      user_test_history = {:board_id=> board_id,:degree_id=> degree_id,
                           :course_id=> course_id,:mcq=> params[:mcq],
                           :truefalse=> params[:true_false],:fill=> params[:fill],
                           :descriptive=> params[:descriptive], :quiz_name => "Own Test",
                           :user_id=> user.id}
      puts "new puts===>>>",user_test_history.inspect
      user_history = UserTestHistory.new(user_test_history)
      puts "new userhistory------",user_history.inspect
      user_history.save

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
      user_test_history = {:board_id=> board_id,:degree_id=> degree_id, :session => session,
                           :course_id=> course_id, :year => year,
                           :quiz_name => "Past Paper Test",
                           :user_id=> user.id}
      puts "new puts===>>>",user_test_history.inspect
      user_history = UserTestHistory.new(user_test_history)
      puts "new userhistory------",user_history.inspect
      user_history.save

      questions_data = Question.joins("INNER JOIN past_paper_histories p ON questions.id = p.question_id").where(
          "p.course_id = ? and p.year = ? and p.session = ?
                               and deleted = 'false'
                              and workflow_state = 'accepted'" ,course_id.to_s,year.to_s,session.to_s )
      @questions = questions_data.select{|x|  x.topic_ids.present? &&
          # (selected_topic_ids.include?(x.topic_ids.split(",")[0]) ||
          #     selected_topic_ids.include?(x.topic_ids.split(",")[1]) ||
          #     selected_topic_ids.include?(x.topic_ids.split(",")[2]) ||
          #     selected_topic_ids.include?(x.topic_ids.split(",")[3])) &&
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
            {:id => o.id, :question_id => o.question_id, :flag => o.flag, :image_url => o.avatar.url(:medium), :statement => o.statement.present? ? o.statement : "NNNN", :is_answer => o.is_answer}
          end
        }
      end
      @time_allowed = @questionlist.count * 1.5

      render :json => {:success => true, :questions => @questionlist, :time_allowed => @time_allowed, :user_test_history_id => user_history.id}
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
    @quizzes = UserTestHistory.where(:user_id => @student.id).order('created_at DESC')
    @quizzes = @quizzes.map{|quiz|
      {
          :test_name => quiz.quiz_name,
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

  def verify_answers_web
    puts "===========================>", params.inspect
    @score = 0
    @questions = Hash.new
    @questions[:mcq] = Hash.new
    @questions[:fill] = Hash.new
    @questions[:truefalse] = Hash.new
    @questions[:mcq][:total] = 0
    @questions[:fill][:total] = 0
    @questions[:truefalse][:total] = 0
    @questions[:mcq][:attempted] = 0
    @questions[:fill][:attempted] = 0
    @questions[:truefalse][:attempted] = 0
    @questions[:mcq][:correct] = 0
    @questions[:fill][:correct] = 0
    @questions[:truefalse][:correct] = 0

    array = params[:array].split(",")

    @total_questions = array.length
    @total_correct = 0
    @total_wrong = array.length
    @total = array.length
    array.each do |ques|
      @question = Question.find(ques.split(":")[0])
      if @question.question_type == 1
        @questions[:mcq][:total] += 1
        if ques.split(":")[1]
          @questions[:mcq][:attempted] += 1
          if ques.split(":")[1] != 'ref_0' && ques.split(":")[1] != 'ref_1' && ques.split(":")[1] != 'ref_2' && ques.split(":")[1] != 'ref_3'
            @option = Option.find_by_id(ques.split(":")[1])
            if @option.present? && @option.is_answer == 1
              @score += 1
              @questions[:mcq][:correct] += 1
              @total_correct += 1
              @total_wrong -= 1
            end
          end
        end
      elsif @question.question_type == 4
        @questions[:truefalse][:total] += 1
        @option = @question.options.first
        if ques.split(":")[1]
          @questions[:truefalse][:attempted] += 1
          if @option.statement == ques.split(":")[1]
            @score += 1
            @questions[:truefalse][:correct] += 1
            @total_correct += 1
            @total_wrong -= 1
          end
        end
      elsif @question.question_type == 3
        @questions[:fill][:total] += 1
        @options = @question.options.last.statement.split("/")
        if ques.split(":")[1]
          @questions[:fill][:attempted] += 1
          @options.each do |opt|
            if opt == ques.split(":")[1]
              @score += 1
              @questions[:fill][:correct] += 1
              @total_correct += 1
              @total_wrong -= 1
              break
            end
          end
        end
      end
    end

    @questions[:mcq][:percentage] = (( (@questions[:mcq][:correct]+0.0) / @questions[:mcq][:total] )*100).round(2)
    if @questions[:mcq][:percentage].nan?
      @questions[:mcq][:percentage] = 0.0
    end
    @questions[:fill][:percentage] = (( (@questions[:fill][:correct]+0.0) / @questions[:fill][:total] )*100).round(2)
    if @questions[:fill][:percentage].nan?
      @questions[:fill][:percentage] = 0.0
    end
    @questions[:truefalse][:percentage] = (( (@questions[:truefalse][:correct]+0.0) / @questions[:truefalse][:total] )*100).round(2)
    if @questions[:truefalse][:percentage].nan?
      @questions[:truefalse][:percentage] = 0.0
    end
    @overall_percentage = (( (@total_correct+0.0) / @total_questions )*100).round(2)
    if @overall_percentage.nan?
      @overall_percentage = 0.0
    end

    if @overall_percentage >= 90
      @grade = "A*"
    elsif @overall_percentage >=85 && @overall_percentage < 90
      @grade = "A"
    elsif @overall_percentage >=75 && @overall_percentage < 85
      @grade = "B"
    elsif @overall_percentage >=65 && @overall_percentage < 75
      @grade = "C"
    elsif @overall_percentage >=55 && @overall_percentage < 65
      @grade = "D"
    elsif @overall_percentage >=45 && @overall_percentage < 55
      @grade = "E"
    elsif @overall_percentage < 45
      @grade = "F"
    end



    test_history = UserTestHistory.find(params[:test_history_id])
    if test_history.code
      quiz = Quiz.find_by_test_code(test_history.code)
      unless quiz.attempted
        quiz.update_attributes(:attempted => true)
      end


      user_ids = UserTestHistory.where(:code => test_history.code).uniq.pluck(:user_id)
      users = User.where("id IN (?)", user_ids)
      scores = Array.new
      users.each do |user|
        scores << user.user_test_histories.last.score.to_i
      end

      test_history.score = @total_correct
      test_history.total = @total
      test_history.is_live = false
      test_history.save!
      test_total_marks = test_history.total

      @test_highest = scores[0]
      @test_lowest = scores[0]
      sum_of_marks = 0
      scores.each do|score|
        sum_of_marks += score
        if score > @test_highest
          @test_highest = score
        end
      end
      scores.each do|score|
        if score < @test_lowest
          @test_lowest = score
        end
      end

      @test_average = sum_of_marks/scores.length
      @test_average_percentage = (( (@test_average+0.0) / test_total_marks ) * 100).round(2)

      @test_highest_percentage = (( (@test_highest+0.0) / test_total_marks ) * 100).round(2)
      @test_lowest_percentage = (( (@test_lowest+0.0) / test_total_marks ) * 100).round(2)
      @time_allowed = array.length * 1.5
      @teacher_name = User.find(quiz.user_id).name
      course = quiz.course
      @course_name = course.name
      bdgree = course.board_degree_assignments.first
      @board_name = bdgree.board.name
      @degree_name = bdgree.degree.name

      @test_code = test_history.code
      @test_name = quiz.name

    else
      test_history.score = @total_correct
      test_history.total = @total
      test_history.is_live = false
      test_history.save!
      test_total_marks = test_history.total

      @course_name = Course.find(test_history.course_id).name
      @board_name = Board.find(test_history.board_id).name
      @degree_name = Degree.find(test_history.degree_id).name
      if session[:quiz_time] == '-1'
        @time_allowed = @total * 1.5
      else
        @time_allowed = session[:quiz_time]
      end
    end



    if params[:user_test_history_id]
      test = UserTestHistory.find(params[:user_test_history_id])
      test.score = @score
      test.total = @total
      test.is_live = false
      test.save!
    end

    render "home_page/result"

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

  def verify_answers
    puts "===========================>", params.inspect
    @score = 0

    array = params[:array].split(",")


    @total = array.length
    array.each do |ques|
      @question = Question.find(ques.split(":")[0])
      if @question.question_type == 1
        if ques.split(":")[1]
          if ques.split(":")[1] != 'ref_0' && ques.split(":")[1] != 'ref_1' && ques.split(":")[1] != 'ref_2' && ques.split(":")[1] != 'ref_3'
            @option = Option.find_by_id(ques.split(":")[1])
            if @option.present? && @option.is_answer == 1
              @score += 1
            end
          end
        end
      elsif @question.question_type == 4
        @option = @question.options.first
        if ques.split(":")[1]
          if @option.statement == ques.split(":")[1]
            @score += 1
          end
        end
      elsif @question.question_type == 3
        @options = @question.options.last.statement.split("/")
        if ques.split(":")[1]
          @options.each do |opt|
            if opt == ques.split(":")[1]
              @score += 1
              break
            end
          end
        end
      end
    end





    if params[:user_test_history_id]
      test = UserTestHistory.find(params[:user_test_history_id])
      test.score = @score
      test.total = @total
      test.is_live = false
      test.save!
    end

    render :json => {:success => true, :score => @score, :total => @total}

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

  def get_live_score_list
    user = User.find_by_email(params[:email])
    quizzes = Quiz.where(:user_id => user.id, :attempted => true)
    count = Hash.new
    quizzes.each do |quiz|
      count[quiz.test_code] = UserTestHistory.where(:code => quiz.test_code).uniq.pluck(:user_id).count
    end
    status = Hash.new
    quizzes.each do |quiz|
      status[quiz.test_code] = UserTestHistory.where("code = ? AND is_live = ?",quiz.test_code, true ).present? ? "Attempting" : "Attempted"
    end
    @quizzes = quizzes.map do |quiz|
      {
          :test_code => quiz.test_code,
          :test_name => quiz.name,
          :status => status[quiz.test_code],
          :count => count[quiz.test_code]
      }
    end
    @quizzes.each do |quiz|
      if quiz[:count] == 0
        @quizzes.delete_at(@quizzes.index(quiz))
      end
    end
    if @quizzes.present?
      render :json => {:success => true, :quizzes => @quizzes}
    else
      render :json => {:success => false}
    end
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
          where("(course_1  IN (?) OR course_2  IN (?) OR course_3  IN (?) OR course_4  IN (?)) and author = ? and workflow_state = 'accepted'", course_id, course_id, course_id, course_id, email).limit(limit).offset(offset)
      @count = Question.select("questions.*").
          joins(:course_linking).
          where("(course_1  IN (?) OR course_2  IN (?) OR course_3  IN (?) OR course_4  IN (?)) and author = ? and workflow_state = 'accepted'", course_id, course_id, course_id, course_id, email).length
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
          where("(course_1  IN (?) OR course_2  IN (?) OR course_3  IN (?) OR course_4  IN (?)) and author = ? and workflow_state = 'accepted'", course_id, course_id, course_id, course_id, email).limit(100).offset(offset)
      @count = Question.select("questions.*").
          joins(:course_linking).
          where("(course_1  IN (?) OR course_2  IN (?) OR course_3  IN (?) OR course_4  IN (?)) and author = ? and workflow_state = 'accepted'", course_id, course_id, course_id, course_id, email).length
      if @questions.size == 0
        render :json => {:success => false}
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
    @quiz.time_allowed = params[:question_ids].split(',').count * 1.5 if params[:question_ids]
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
