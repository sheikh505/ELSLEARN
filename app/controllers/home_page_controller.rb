class HomePageController < ApplicationController
  load_and_authorize_resource

  def index
    if user_signed_in?
      @user = current_user
    else
      @user = User.new
    end
    @news_feed = NewsFeed.last
    @boards = Board.all
    @degrees = []
    @degrees << 'select board first'

    @courses = []
    @topics = []
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

    puts "========================>"+past_papers.inspect

    past_papers.each do |paper|
      question_ids << paper.question_id
    end
    all_questions_with_fetched_ids = Question.where("id IN (?) and
                                            deleted = 'false' and
                                            workflow_state = 'accepted'", question_ids)
    puts "========================>" + all_questions_with_fetched_ids.inspect
    @varients = []
    all_questions_with_fetched_ids.each do |question_varient|
      @varients<<question_varient.varient
    end
    @varients.compact!
    @varients.uniq!

    render :partial => 'home_page/varient_list'
  end


  def about_us

  end

  def admin_panel
    @questions_mcq_publish =  Question.where("deleted = 'false' and workflow_state = 'accepted' and question_type ='1'").count
    @questions_mcq_not_publish = Question.where("deleted = 'false' and (workflow_state != 'accepted' or workflow_state is null) and question_type = '1' ").count
    @total_questions_mcq = Question.where("deleted = 'false' and question_type ='1'").count
    @questions_truefalse_publish = Question.where("deleted = 'false' and workflow_state = 'accepted' and question_type ='4'").count
    @questions_truefalse_not_publish = Question.where("deleted = 'false' and workflow_state != 'accepted' and question_type ='4'").count
    @total_questions_truefalse = Question.where("deleted = 'false' and question_type ='4'").count
    @questions_blank_publish = Question.where("deleted = 'false' and workflow_state = 'accepted' and question_type ='3'").count
    @questions_blank_not_publish = Question.where("deleted = 'false' and workflow_state != 'accepted' and question_type ='3'").count
    @total_questions_blank = Question.where("deleted = 'false' and question_type ='3'").count
    @questions_descriptive_publish = Question.where("deleted = 'false' and workflow_state = 'accepted' and question_type ='2'").count
    @questions_descriptive_not_publish = Question.where("deleted = 'false' and workflow_state != 'accepted' and question_type ='2'").count
    @total_questions_descriptive = Question.where("deleted = 'false' and question_type ='2'").count
    @total_publish = Question.where("deleted = 'false' and workflow_state = 'accepted' ").count
    @total_not_publish = Question.where("deleted = 'false' and (workflow_state != 'accepted' or workflow_state is null)").count
    @total_questions = Question.where("deleted = 'false' ").count
    @admin_users = User.joins(:assignments, :roles).where("assignments.role_id = '4' ").count
    @student_users = User.joins(:assignments, :roles).where("assignments.role_id = '5' ").count
    @operator_users = User.joins(:assignments, :roles).where("assignments.role_id = '6' ").count
    @teacher_users = User.joins(:assignments, :roles).where("assignments.role_id = '8' ").count
    @hod_users = User.joins(:assignments, :roles).where("assignments.role_id = '9' ").count
    @proofreader_users = User.joins(:assignments, :roles).where("assignments.role_id = '10' ").count
    @total_users = User.count
    render :layout => "admin_panel_layout"
  end

  def get_backup
    `PGPASSWORD=Elslearn001 pg_dump -U postgres elslearn > elslearnbackup.sql`
    # `sudo -u postgres PGPASSWORD="Elslearn001" pg_dump elslearn >   elslearnbackup.sql`
    # `scp -i els_live.pem ubuntu@54.236.217.115:/var/www/elslearn/elslearnbackup.sql ~/project/elslearn`
    send_file Rails.root.join('elslearnbackup.sql'), :type=>"application/sql", :x_sendfile=>true
  end

  def get_courses
    if current_user.is_admin?
      degree_id = params[:degree_id]
      board_id = params[:board_id]
      bdgree = BoardDegreeAssignment.find_all_by_board_id_and_degree_id(board_id,degree_id)
      course_ids = DegreeCourseAssignment.where(:board_degree_assignment_id => bdgree.first.id).pluck(:course_id)
      @courses = Course.find(course_ids)
      render :partial => 'home_page/c_list'
    else
      @courses = []
      degree_id = params[:degree_id]
      board_id = params[:board_id]

      @courses = BoardDegreeAssignment.find_all_by_board_id_and_degree_id(board_id,degree_id)
      course_ids = UserPackage.where(user_id: current_user.id).pluck(:course_id)
      @courses = Course.where("id IN (?)", course_ids)
      @flag = false
      render :partial => 'home_page/c_list'
    end
  end

  def remove_image
    @answer_image = AnswerImage.find_by_id(params[:answer_image_id])
    @answer_image.delete
    render nothing: true
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

  def check_package
    @quiz = Quiz.find_by_test_code(params[:test_code])
    isStudentAllowed = true
    if !current_user.teacher_requests.present?
      isStudentAllowed = false
    end

    if @quiz.present?
      teacher_token = User.find(@quiz.user_id).teacher_token
      if teacher_token.present?
        if !current_user.teacher_requests.where(:teacher_token => teacher_token).present?
          isStudentAllowed = false
        end
      else
        isStudentAllowed = false
      end
    end

    if !isStudentAllowed
      render json: {
          success: false,
          flag: "student_not_allowed"
      }, status: 500
      return
    end

    if !@quiz.present? && isStudentAllowed
      render json: {
          success: false,
          flag: "not_present"
      }, status: 500
      return
    elsif !current_user.user_packages.where(course_id: @quiz.course_id).any?
      render json: {
          success: false,
          flag: "not_registered"
      }, status: 500
      return
    end

    user_package = current_user.user_packages.where(course_id: @quiz.course_id).first
    if user_package.plan != "free"
      if user_package.validity < Time.now
        render json: {
            success: false,
            flag: "package_expired"
        }, status: 500
        return
      else
        credit = user_package.credit_left
        question_ids = @quiz.question_ids.split(",")
        puts "++++====================>>>", Question.where(id: question_ids.split(','), question_type: 2).inspect
        count = Question.where(id: question_ids.split(','), question_type: 2).count
        credit = credit - (QuestionQuota.find_by_question_type(2).quota * count)
        if credit < 0
          render json: {
              success: false,
              flag: "credit_limit"
          }, status: 500
          return
        end
      end
    else
      question_ids = @quiz.question_ids.split(",")
      questions = Question.where(id: question_ids.split(','), question_type: 2)
      if questions.any?
        render json: {
            success: false,
            flag: "free_package"
        }, status: 500
        return
      end
    end
    render json: {
        success: true,
        url: url_for(home_page_instructions_path(test_code: params[:test_code], test_flag: params[:test_flag]))
    }, status: 200
  end

  def instructions
    puts "new puts===>>>>>>>>>>>>>>>>>>>>>>>",params[:quiz_time].inspect
    session[:quiz_time] = params[:quiz_time]
    if params[:test_flag] == "2"
      @test_code = params[:test_code]
      @quiz = Quiz.find_by_test_code(params[:test_code])

      session[:board_id] = ""
      session[:degree_id] = ""
      session[:course_id] = @quiz.course_id
      session[:year] = ""
      session[:session] = ""
      # if UserPackage.where(course_id: @quiz.course_id, user_id: current_user.id).first.plan == "free"
      #   @mcq = @fill = @descriptive = []
      #   @quiz.question_ids.split(",").each do |id|
      #     question = Question.find(id)
      #     if question.question_type == 1
      #       @mcq += 1
      #     elsif question.question_type == 4
      #       @truefalse += 1
      #     elsif question.question_type == 3
      #       @fill += 1
      #     else
      #
      #     end
      #   end
      #   session[:mcq] = @mcq
      #   session[:fill] = @fill
      #   session[:true_false] = @truefalse
      #
      #
      #   if user_signed_in?
      #     user_test_history = {:course_id=> @quiz.course_id,:mcq=> @mcq,
      #                          :truefalse=> @truefalse,:fill=> @fill,
      #                          :quiz_name => @quiz.name,
      #                          :code => params[:test_code],
      #                          :user_id=> current_user.id, :is_live => true}
      #     puts "new puts===>>>",user_test_history.inspect
      #     user_history = UserTestHistory.new(user_test_history)
      #     puts "new userhistory------",user_history.inspect
      #     user_history.save
      #     @user_test_history_id = user_history.id
      #   end
      # else
        @mcq = []
        @fill = []
        @descriptive = []
        @truefalse = []
        @quiz.question_ids.split(",").each do |id|
          question = Question.find(id)
          if question.question_type == 1
            @mcq << question.id
          elsif question.question_type == 4
            @truefalse << question.id
          elsif question.question_type == 3
            @fill << question.id
          else
            @descriptive << question.id
          end
        end
        @mcq = @mcq.join(',') == "" ? nil : @mcq.join(',')
        @fill = @fill.join(',') == "" ? nil : @fill.join(',')
        @truefalse = @truefalse.join(',') == "" ? nil : @truefalse.join(',')
        @descriptive = @descriptive.join(',') == "" ? nil : @descriptive.join(',')
        session[:mcq] = @mcq
        session[:fill] = @fill
        session[:true_false] = @truefalse
        session[:descriptive] = @descriptive


        if user_signed_in?
          user_test_history = {:course_id=> @quiz.course_id,:mcq=> @mcq,
                               :truefalse=> @truefalse,:fill=> @fill,
                               :descriptive=> @descriptive, :quiz_name => @quiz.name,
                               :code => params[:test_code],
                               :user_id=> current_user.id, :is_live => true}
          puts "new puts===>>>",user_test_history.inspect
          user_history = UserTestHistory.new(user_test_history)
          puts "new userhistory------",user_history.inspect
          user_history.save
          @user_test_history_id = user_history.id
        end
      # end


    elsif params[:uthid].present?

      @user_test_history_id = params[:uthid]
      @user_test_history = UserTestHistory.find(@user_test_history_id)
      session[:board_id] = @user_test_history.board_id
      session[:degree_id] = @user_test_history.degree_id
      session[:course_id] = @user_test_history.course_id
      session[:year] = @user_test_history.year
      session[:session] = @user_test_history.session
      session[:mcq] = @user_test_history.mcq
      session[:fill] = @user_test_history.fill
      session[:true_false] = @user_test_history.truefalse
      session[:descriptive] = @user_test_history.descriptive

      if user_signed_in?
        user_test_history = {:board_id=> @user_test_history.board_id,:degree_id=> @user_test_history.degree_id,
                             :course_id=> @user_test_history.course_id,:mcq=> @user_test_history.mcq,
                             :truefalse=> @user_test_history.truefalse,:fill=> @user_test_history.fill,
                             :descriptive=> @user_test_history.descriptive, :quiz_name => "Past Paper",
                             :year=> @user_test_history.year, :session=> @user_test_history.session,
                             :user_id=>current_user.id, :topic_ids => @user_test_history.topic_ids}
        puts "new puts===>>>",user_test_history.inspect
        user_history = UserTestHistory.new(user_test_history)
        puts "new userhistory------",user_history.inspect
        user_history.save
        @user_test_history_id = user_history.id
      end

    else

      @board_id = params[:b_id]
      session[:board_id] = @board_id
      @degree_id = params[:degree_id]
      session[:degree_id] = @degree_id
      session[:varient] = params[:varient]
      @course_id = params[:course]
      list = []
      topics = Course.find(@course_id).topics
      topic_ids = []
      topics.each do |topic|
        topic_ids << topic.id
      end
      selected_topic_ids = topic_ids
      selected_topic_ids.each do |a|
        list << a.to_i
      end
      session[:course_id] = @course_id
      @past_paper_flag = params[:pre_Past]
      session[:past_paper_flag] = @past_paper_flag
      @year = params[:year]
      session[:year] = @year
      @session = params[:session]
      session[:session] = @session
      @mcq = params[:mcq]
      @fill = params[:fill]
      @true_false = params[:true_false]
      @descriptive = params[:descriptive]
      if user_signed_in?
        @user = current_user
      else
        @user = User.new
      end

      if user_signed_in?
        user_test_history = {:board_id=> @board_id,:degree_id=> @degree_id,
                             :course_id=> @course_id, :quiz_name => "Own Test",
                             :mcq => @mcq, :truefalse => @true_false, :fill => @fill, :descriptive => @descriptive,
                             :pastpaperflag=> @past_paper_flag,
                             :year=> @year, :session=> @session, :user_id=>current_user.id, :topic_ids => list.join(",")}
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
      deg_id = @degree_id.to_s
      selected_topic_ids = user_test_history[:topic_ids]
      puts "$$$$$$$$$$$$",selected_topic_ids.inspect
      puts "==========---------====",@course_id.inspect
      @mcq = user_test_history[:mcq]
      @fill = user_test_history[:fill]
      @true_false = user_test_history[:truefalse]
      @descriptive = user_test_history[:descriptive]
      @past_paper_flag = user_test_history[:pastpaperflag]
      @year = user_test_history[:year]
      @session = user_test_history[:session]
      bd = BoardDegreeAssignment.find_by_board_id_and_degree_id(@board_id,@degree_id)
      @questions = []
      @course = Course.find(@course_id).name
      if @past_paper_flag.to_i == 2
        @quiz_time = session[:quiz_time]
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

        mcq = []
        fill = []
        truefalse = []
        descriptive = []

        list.each do |question|
          if question.question_type == 1 && i < @mcq.to_i
            @questions << question
            mcq << question.id
            puts "=================>mcq" + question.id.inspect
            i += 1
          elsif question.question_type == 4 && j < @true_false.to_i
            @questions << question
            truefalse << question.id
            puts "=================>truefalse" + question.id.inspect
            j += 1
          elsif question.question_type == 3 && k < @fill.to_i
            @questions << question
            fill << question.id
            puts "=================>fill" + question.id.inspect
            k += 1
          elsif question.question_type == 2 && l < @descriptive.to_i
            @questions << question
            descriptive << question.id
            puts "=================>descriptive" + question.id.inspect
            l += 1
          end
        end

        mcq = mcq.join(',') == "" ? nil : mcq.join(',')
        fill = fill.join(',') == "" ? nil : fill.join(',')
        truefalse = truefalse.join(',') == "" ? nil : truefalse.join(',')
        descriptive = descriptive.join(',') == "" ? nil : descriptive.join(',')

        user_test_history.update_attributes(mcq: mcq, fill: fill, truefalse: truefalse, descriptive: descriptive)


      elsif @past_paper_flag.to_i == 1
        @varient = session[:varient]
        questions_data = Question.joins("INNER JOIN past_paper_histories p ON questions.id = p.question_id").where(
            "p.course_id = ? and p.year = ? and p.session = ?
                               and deleted = 'false'
                              and workflow_state = 'accepted'" ,@course_id.to_s,@year.to_s,@session.to_s )
        @questions = questions_data.select{ |q| q.varient == @varient.to_s }
        # @questions_data = Question.joins("INNER JOIN past_paper_histories p ON questions.id = p.question_id").where(
        #                      "p.course_id = ? and p.year = ? and p.session = ?
        #                        and deleted = 'false'
        #                       and workflow_state = 'accepted'" ,@course_id.to_s,@year.to_s,@session.to_s )
        # puts "&&&&&&&&&&&",@questions_data.inspect
        # list = @questions_data.select{|x|  x.topic_ids.present? &&
        #     (selected_topic_ids.include?(x.topic_ids.split(",")[0]) ||
        #         selected_topic_ids.include?(x.topic_ids.split(",")[1]) ||
        #         selected_topic_ids.include?(x.topic_ids.split(",")[2]) ||
        #         selected_topic_ids.include?(x.topic_ids.split(",")[3])) &&
        #         x.degree_ids.present? && (deg_id.include?(x.degree_ids.split(",")[0])||
        #     deg_id.include?(x.degree_ids.split(",")[1]) ||
        #     deg_id.include?(x.degree_ids.split(",")[2]) ||
        #     deg_id.include?(x.degree_ids.split(",")[3]) )}

        # @questions = Question.select { |q| q.deleted == false &&
        #     q.past_paper_history.present? &&
        #     q.past_paper_history.course_id == @course_id.to_i  &&
        #     #q.past_paper_history.ques_no == ques_no.to_s &&
        #     q.past_paper_history.year == @year.to_s &&
        #     q.past_paper_history.session == @session.to_s
        #     q.varient == @varient.to_s &&
        #     q.workflow_state == 'accepted' }

        # puts "^^^^^^^^%%%%%%",list.inspect
        # @questions = list.shuffle
        puts "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&",@questions.inspect,@questions.count

        @mcq = []
        @fill = []
        @descriptive = []
        @truefalse = []

        @questions.each do |ques|
          if ques.question_type == 1
            @mcq << ques.id
          elsif ques.question_type == 4
            @true_false << ques.id
          elsif ques.question_type == 3
            @fill << ques.id
          else
            @descriptive << ques.id
          end
        end

        @mcq = @mcq.join(',') == "" ? nil : @mcq.join(',')
        @fill = @fill.join(',') == "" ? nil : @fill.join(',')
        @truefalse = @truefalse.join(',') == "" ? nil : @truefalse.join(',')
        @descriptive = @descriptive.join(',') == "" ? nil : @descriptive.join(',')

        user_test_history.update_attributes(mcq: @mcq, fill: @fill, truefalse: @true_false, descriptive: @descriptive)

        @size = @questions.length
        @quiz_time = @size * 1.5
        @index = 0
      else
        quiz = Quiz.find_by_test_code(user_test_history[:code])
        if quiz.present?
          question_ids = quiz.question_ids
          @questions = Question.find(question_ids.split(','))
          @size = @questions.length
          @quiz_time = @size * 1.5
        else
          render :nothing=>true
        end
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
        @size = @questions.length
        @quiz_time = @size * 1.5
      else
        render :nothing=>true
      end
    end

    @user = current_user

    if @questions.present?
      puts "%%%%%%%%%%% if question present ? %%%%%%%",@questions.inspect
      @size = @questions.length
      @questions.shuffle!
      # puts "%%%%%%%%%%% if question present ? %%%%%%%",@size.inspect
      # die

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

  def check_student_package
    user_test_history = UserTestHistory.find(params[:user_test_history_id])
    user_package = current_user.user_packages.where(:course_id => user_test_history.course_id).first
    teacher_tokens = TeacherRequest.where(:student_id => current_user.id).pluck(:teacher_token)
    @teacher_ids = TeacherCourse.where("course_id = ?", user_test_history.course_id).pluck(:user_id)
    session[:course_id] = user_test_history.course_id
    puts "===========>" + teacher_tokens.inspect
    session[:teacher_tokens] = teacher_tokens
    @teacher_ids << User.where(:email => "admin@els.com").first.id
    puts "================>"
    if user_test_history.descriptive
      render json: {success: true, teacher_ids: @teacher_ids.join(','), user_package: user_package ? user_package.package.flag : "1"}
    else
      render json: {success: true, teacher_ids: @teacher_ids.join(','), user_package: "1"}
    end
  end

  def fetch_teachers
    @els = User.find(params[:teacher_ids].split(',').pop)
    if session[:teacher_tokens].any?
      @teachers = User.where("id IN (?)", params[:teacher_ids].split(','))
      @teachers = @teachers.select{|teacher|
        teacher.review_permission_ids != nil &&
        teacher.review_permission_ids.split(',').include?("2") &&
        session[:teacher_tokens].include?(teacher.teacher_token)
      }
    else
      @teachers = []
    end

    render partial: "fetch_teachers"
  end

  def get_teachers
    teacher_tokens = TeacherRequest.where(:student_id => current_user.id).pluck(:teacher_token)
    if teacher_tokens.any?
      teacher_ids = TeacherCourse.where("course_id = ?", session[:course_id]).pluck(:user_id)
      teacher_ids = TeacherCourse.where(course_id: session[:course_id]).pluck(:user_id)
      @teachers = User.where("id IN (?) AND review_permission_ids != ''", teacher_ids)
      @teachers = @teachers.select{|teacher|
        teacher.review_permission_ids != nil &&
        teacher.review_permission_ids.split(',').include?(params[:review]) &&
        teacher_tokens.include?(teacher.teacher_token)
      }
    else
      @teachers = []
    end

    render partial: "get_teachers"
  end

  def upload_image
    @answer = Answer.where(question_id: params[:answer][:question_id], user_test_history_id: params[:answer][:user_test_history_id]).first
    if @answer
      @answer_image = AnswerImage.create(answer_id: @answer.id, image: params[:answer][:image])
    else
      @answer = Answer.create(question_id: params[:answer][:question_id], user_test_history_id: params[:answer][:user_test_history_id])
      @answer_image = AnswerImage.create(answer_id: @answer.id, image: params[:answer][:image])
    end
    render partial: "answer_image"
  end

  def payments
    @students = User.joins("INNER JOIN assignments a ON users.id = a.user_id").where("a.role_id = 5")
    @students = @students.map do |student|
      certification = Degree.find_by_id(student.degree_id)
      certification = certification ? certification.name : ""
      user_packages = student.user_packages
      courses = 0
      amount = 0
      if user_packages.any?
        user_packages.each do |package|
          courses = courses + 1
          amount = amount + package.package.price
        end
        {
            :id => student.id,
            :name => student.name,
            :courses => courses,
            :amount => amount,
            :status => student.is_active ? "Successful" : "Pending",
            :is_active => student.is_active,
            :certification => certification,
            :method => amount == 0 ? "Free" : "Credit Card"
        }
      else
        {
            :id => student.id,
            :name => student.name,
            :courses => courses,
            :amount => amount,
            :status => student.is_active ? "Successful" : "Pending",
            :is_active => student.is_active,
            :certification => certification,
            :method => amount == 0 ? "Free" : "Credit Card"
        }
      end
    end
    render "payments", layout: "admin_panel_layout"
  end

  def set_access
    @student = User.find(params[:id])
    puts "================>" + @student.inspect, @student.is_active
    if @student.is_active
      @student.is_active = false
    else
      @student.is_active = true
    end
    if @student.save
      render json: {:success => true}
    else
      render json: {:success => false}
    end
  end

  def get_details
    @student = User.find(params[:id])
    @packages = @student.user_packages
    @certification = Degree.find_by_id(@student.degree_id)
    render partial: "get_details"
  end

  def add_user_test

    user_history = UserTestHistory.new(:score=> params[:score],:total=> params[:total],:course_id=> Course.find_by_id(params[:course]).name,:user_id=> current_user.id,:code=> nil)
    user_history.save

    redirect_to root_path

  end

  def create_user_registration
    list = []
    selected_topic_ids = params[:topic_ids]
    selected_topic_ids.each do |a|
      list << a.to_i
    end
    unless user_signed_in?
      @user = User.new(params[:user])

      if @user.save
        sign_in @user
        assignment = Assignment.new(:user_id=> @user.id,:role_id=> Role.find_by_name('Student').id)
        assignment.save
        user_test_history = {:board_id=> params[:b_id],:degree_id=> params[:degree_id],
                             :course_id=> params[:course],:mcq=> params[:mcq],
                             :truefalse=> params[:true_false],:fill=> params[:fill],
                             :descriptive=> params[:descriptive], :pastpaperflag=> params[:pre_Past],
                             :year=> params[:year], :session=> params[:session], :user_id=>current_user.id,:topic_ids => list.join(",")}
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
    list = []
    selected_topic_ids = params[:topic_ids]
    selected_topic_ids.each do |a|
      list << a.to_i
    end
    user = User.find_by_email(params[:new_user][:email])
    if user.present? && user.valid_password?(params[:new_user][:password])
      sign_in user
      user_test_history = {:board_id=> params[:b_id],:degree_id=> params[:degree_id],
                           :course_id=> params[:course],:mcq=> params[:mcq],
                           :truefalse=> params[:true_false],:fill=> params[:fill],
                           :descriptive=> params[:descriptive], :pastpaperflag=> params[:pre_Past],
                           :year=> params[:year], :session=> params[:session], :user_id=>current_user.id,:topic_ids => list.join(",")}
      user_history = UserTestHistory.new(user_test_history)
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
    session[params[:ques_id]] = params[:choice]
    puts "========================>@@@@@@" + params[:ques_id].inspect + params[:choice].inspect
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

  def get_session
    arr = params[:ques_id_array].split(",")
    @array = Array.new
    arr.each do |i|
      str = i + ":" + session[i].to_s
      session[i] = nil
      @array << str
      puts "========================>@@@@@@" + str.inspect
    end
    @array = @array.join('#')
    puts "========================>" + @array.inspect
    render :json => {:array => @array}
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
    @course_id = params[:course]

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
    @news_feed = NewsFeed.last

  end

  def try_it

    @past_papers = PastPaperHistory.all
    @years = []
    @past_papers.each do |paper|
      @years << paper.year
    end

    @years.uniq!
    @years.sort!
    @years.reverse!
    if user_signed_in?
      @user = current_user
    else
      @user = User.new
    end

    if current_user.is_admin?
      @boards = Board.all
      # @boards = Array.new
      # boards.each do |board|
      #   @boards << board.id
      # end
      @degrees = Degree.all
      # @degrees = Array.new
      # degrees.each do |degree|
      #   @degrees << degree.id
      # end
      @courses = []
    elsif valid_packages(current_user.id).any?
      course_ids = valid_packages(current_user.id).pluck(:course_id)
      @courses = Course.where("id IN (?) AND enable=true", course_ids)
      if @courses.any?
        d_c_assignment = @courses.first.degree_course_assignments.first
        bdgree = BoardDegreeAssignment.find(d_c_assignment.board_degree_assignment_id)
        @boards = bdgree.board_id
        @degrees = bdgree.degree_id
      else
        @courses = []
        @degrees = []
        @boards = []
      end
    else
      @courses = []
      @degrees = []
      @boards = []
    end

    @topics = []
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
  end


  def get_topic
    if current_user.is_admin?
      a = params[:course_id]
      @topics = Topic.where("course_id = ?",a).order(:created_at)
      render :partial => 'home_page/topic_list'
    else
      a = params[:course_id]
      package = UserPackage.where(:user_id => current_user, :course_id => params[:course_id]).first
      if package.plan == "free"
        @plan = false
      else
        @plan = true
      end
      puts "=======alert===>>>>>>",a.inspect
      @topics = Topic.where("course_id = ?",a).order(:created_at)
      puts "----=-=======-",@topics.inspect
      render :partial => 'home_page/topic_list'
    end
  end

  def how_it_works
  end

  def testimonials

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
