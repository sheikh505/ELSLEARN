class HomePageController < ApplicationController

  def index
    if user_signed_in?
      @user = current_user
    else
      @user = User.new
    end

    @boards = Board.all
    @degrees = []
    @degrees << 'select board first'

    @courses = []
    #@courses << 'select board and degree first'

    sql2 = 'SELECT COUNT(q.id) as q_count,c.name as course FROM
           questions as q JOIN topics as t ON q.topic_id = t.id
           JOIN courses as c ON t.course_id = c.id
            GROUP BY c.id
            ORDER BY c.name'
    connection = ActiveRecord::Base.connection
    @question_stats = connection.execute(sql2)

    sql_top_user = 'SELECT SUM(score) as user_score,SUM(total) as total,c.name as course,u.name as name,u.id as user_id FROM
                user_test_histories as h JOIN users as u
                ON h.user_id = u.id
                JOIN courses as c
                ON c.id = h.course_id
                GROUP BY u.id,c.name
                ORDER BY user_score DESC
                LIMIT 5'
    @top_scorer_users = connection.execute(sql_top_user)

    @flag = true
    # sql = "SELECT (float4(score)/float4(total))*100 as percentage, u.id as user_id, u.name, c.name as course_name
    #       FROM user_test_histories uth
    #       INNER JOIN users u ON u.id = uth.user_id
    #       INNER JOIN courses c ON c.id = uth.course_id
    #       where score = total
    #       limit 5"
    #
    # # @top_scorer_users = UserTestHistory.joins(:user, :course).where("score is not null and total is not null and score < total")
    # @top_scorer_users = UserTestHistory.find_by_sql(sql)
    # sql = "DROP TABLE temp;
    #
    #       CREATE TEMP TABLE temp (
    #         course   text
    #       , degree    text
    #       , ct        integer  -- don't use "count" as column name.
    #       );
    #
    #       INSERT INTO temp (course, degree, ct )
    #       (Select  c.name course,  d.name degree, Count(DISTINCT q.id) ct
    #       from questions q
    #       INNER JOIN topics t ON t.id = q.topic_id
    #       INNER JOIN courses c ON t.course_id = c.id
    #       INNER JOIN board_question_assignments bqa ON bqa.question_id = q.id
    #       INNER JOIN board_degree_assignments bda ON bda.id = bqa.board_degree_assignment_id
    #       INNER JOIN degrees d ON d.id = bda.degree_id
    #       --WHERE c.name = 'BIOLOGY' AND d.name = 'A LEVEL'
    #       GROUP BY c.name, d.name
    #       ORDER BY d.name)
    #
    #       SELECT *
    #       FROM   crosstab(
    #             'SELECT course, degree, ct
    #              FROM   temp
    #              ORDER  BY degree desc')
    #       AS ct ('course' text, 'O LEVEL' integer, 'A LEVEL' integer);"
    #
    # @questionsCount = Question.find_by_sql(sql)


    # @notes_degrees = []
    #       #notes degreeesssssss
    #     Book.all.each do |nd|
    #       @notes_degrees << nd.degree
    #     end
    #
    # @notes_course_list = []
    # @notes_list = []

  end

  def get_varients
    question_ids = []
    past_papers = PastPaperHistory.where(year: params[:year], session: params[:session])

    past_papers.each do |paper|
      question_ids << paper.question_id
    end
    all_questions_with_fetched_ids = Question.find(question_ids)
    @varients = []
    all_questions_with_fetched_ids.each do |question_varient|
      @varients<<question_varient.varient
    end
    @varients.compact!
    @varients = @varients.reject { |c| c.empty? }
    @varients.uniq!

    render :partial => 'home_page/varient_list'
  end


  def about_us

  end

  def admin_panel
    render :layout => "admin_panel_layout"
  end

  def get_courses
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
    puts "---------------paramsInspect",params.inspect
    if params[:test_flag] == "2"
      @test_code = params[:test_code]
    elsif params[:uthid].present?
      @user_test_history_id = params[:uthid]
    else
      @board_id = params[:b_id]
      session[:board_id] = @board_id
      @degree_id = params[:degree_id]
      session[:degree_id] = @degree_id
      @course_id = params[:course]
      puts "======courseID=---=>>",@course_id.inspect
      session[:course_id] = @course_id
      @past_paper_flag = params[:pre_Past]
      session[:past_paper_flag] = @past_paper_flag
      @year = params[:year]
      session[:year] = @year
      @session = params[:session]
      session[:session] = @session
      if params[:mcq].blank?
        @mcq = 0
      else
        @mcq = params[:mcq]
      end
      session[:mcq] = @mcq
      if params[:fill].blank?
        @fill = 0
      else
        @fill = params[:fill]
      end
      session[:mcq] = @mcq
      if params[:true_false].blank?
        @true_false = 0
      else
        @true_false = params[:true_false]
      end
      session[:true_false] = @true_false
      if params[:descriptive].blank?
        @descriptive = 0
      else
        @descriptive = params[:descriptive]
      end
      session[:descriptive] = @descriptive
      if user_signed_in?
        @user = current_user
      else
        @user = User.new
      end

      if user_signed_in?
        user_test_history = {:board_id=> @board_id,:degree_id=> @degree_id,
                             :course_id=> @course_id,:mcq=> @mcq,
                             :truefalse=> @true_false,:fill=> @fill,
                             :descriptive=> @descriptive, :pastpaperflag=> @past_paper_flag,
                             :year=> @year, :session=> @session, :user_id=>current_user.id}
        puts "new puts===>>>",user_test_history.inspect
        user_history = UserTestHistory.new(user_test_history)
        puts "new userhistory------",user_history.inspect
        user_history.save
        @user_test_history_id = user_history.id
      end
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
        temp = Question.joins(:question_histories, :course_linking).where(" deleted ='false' and workflow_state='accepted' and varient = '' and course_linking_id = ? " , CourseLinking.search_on_course_column(@course_id).id)
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
        list = Question.joins("INNER JOIN past_paper_histories p ON questions.id = p.question_id").where(
                             "p.course_id = ? and p.year = ? and p.session = ?
                               and deleted = 'false'
                              and workflow_state = 'accepted'" ,@course_id.to_s,@year.to_s,@session.to_s )
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
      else
        render :nothing=>true
      end
    end

    @user = current_user

    if @questions.present?
      @size = @questions.length
      @index = 0
      @answer = Hash.new
      i = 0
      10.times{
        if session[i].present?
          session.delete(i)
        end
        i+=1
      }
      render :layout=> "quiz_layout"
    end
  end

  def add_user_test

    user_history = UserTestHistory.new(:score=> params[:score],:total=> params[:total],:course_id=> Course.find_by_id(params[:course]).name,:user_id=> current_user.id,:code=> nil)
    user_history.save

    redirect_to root_path

  end

  def create_user_registration
    unless user_signed_in?
      @user = User.new(params[:user])

      if @user.save
        sign_in @user
        assignment = Assignment.new(:user_id=> @user.id,:role_id=> Role.find_by_name('Student').id)
        assignment.save
        user_test_history = {:board_id=> params[:b_id],:degree_id=> params[:degree_id],
                             :course_id=> params[:course_id],:mcq=> params[:mcq],
                             :truefalse=> params[:true_false],:fill=> params[:fill],
                             :descriptive=> params[:descriptive], :pastpaperflag=> params[:pre_Past],
                             :year=> params[:year], :session=> params[:session], :user_id=>current_user.id}
        puts "============<<<<<",user_test_history.inspect
        user_history = UserTestHistory.new(user_test_history)
        pputs "<<<<<<<<<<<<<",user_history.inspect
        user_history.save
        render :json => {:success => true, :user_test_history_id => user_history.id}
      else
        render :json => {:success => false, :message => "Email address has already taken."  }
      end

    end
  end

  def sign_in_user
    user = User.find_by_email(params[:new_user][:email])
    if user.present? && user.valid_password?(params[:new_user][:password])
      sign_in user
      user_test_history = {:board_id=> params[:b_id],:degree_id=> params[:degree_id],
                           :course_id=> params[:course_id],:mcq=> params[:mcq],
                           :truefalse=> params[:true_false],:fill=> params[:fill],
                           :descriptive=> params[:descriptive], :pastpaperflag=> params[:pre_Past],
                           :year=> params[:year], :session=> params[:session], :user_id=>current_user.id}
      put "09090909090",user_test_history.inspect
      user_history = UserTestHistory.new(user_test_history)
      puts "784841245599",user_history.inspect
      user_history.save

      render :json => {:success => true, :user_test_history_id => user_history.id}
    else
      render :json => {:success => false}
    end
  end

  def save_data
    user_test_history = {:board_id=> params[:b_id],:degree_id=> params[:degree_id],
                         :course_id=> params[:course_id],:mcq=> params[:mcq],
                         :truefalse=> params[:true_false],:fill=> params[:fill],
                         :descriptive=> params[:descriptive], :pastpaperflag=> params[:pre_Past],
                         :year=> params[:year], :session=> params[:session], :user_id=>current_user.id}
    puts "======UserTestHistory=====",user_test_history.inspect
    user_history = UserTestHistory.new(user_test_history)
    puts "=========--UserHistory=-====",user_history.inspect
    if user_history.save
      render :json => {:success => true, :user_test_history_id => user_history.id}
    else
      render :json => {:success => false}
    end
  end
  def save_answer_to_session
    puts "------------------>", session.inspect
    session[params[:index]] = params[:option_index]
    render :json => {:success => true}
  end
  def get_answer_from_session
    puts "------------------>", session.inspect
    if session[params[:index]].present?
      option_index = session[params[:index]]
      render :json => {:success => true, :option_index =>option_index}
    else
      render :json => {:success => false}
    end
  end

  def is_user_signed_in
    if user_signed_in?
      if params[:b_id].present?
        user_test_history = {:board_id=> params[:b_id],:degree_id=> params[:degree_id],
                             :course_id=> params[:course_id],:mcq=> params[:mcq],
                             :truefalse=> params[:true_false],:fill=> params[:fill],
                             :descriptive=> params[:descriptive], :pastpaperflag=> params[:past_paper_flag],
                             :year=> params[:year], :session=> params[:session], :user_id=>current_user.id}
        user_history = UserTestHistory.new(user_test_history)
        user_history.save
        render :json => {:success => true, :user_test_history_id => user_history.id}
      else
        render :json => {:success => true}
      end

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

  def demo

  end

  def pricing
    @membership_plans = MembershipPlan.order(:price)
  end

  def assign_member_ship_plan
    ###### find current user
    respond_to do |format|
      @flag = true
      if user_signed_in?
        #### updating the membership plan id
        if !params[:id].nil? && MembershipPlan.find(params[:id]).name == 'Free'
          if current_user.update_attribute(:membership_plan_id,params[:id])
            current_user.update_attribute(:free_plan_flag,true)
            @message = "YOUR MEMBERSHIP PLAN HAS BEEN UPDATED"
          else
            @flag = false
            @message = current_user.errors.full_messages.first
          end
        else
          @flag = false
          @message = "PAY YOUR BILL MATE"
        end
      else
        @flag = false
        @message = "Please sign in first"
      end
      format.js
    end
  end

  def checkout_form
    if user_signed_in? && current_user.is_student?

    else
      redirect_to "/home_page/pricing",alert: "Sign up to buy the package"
      return
    end
    @membership_plan = MembershipPlan.find(params[:mm_plan_id])

  end

  def receipt
  puts "============================================================+>",params.inspect
  end

  private
  def check_session

  end

end
