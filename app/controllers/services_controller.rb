class ServicesController < ApplicationController
  respond_to :json
  skip_before_filter :authenticate_user!
  before_filter :check_session, :except => [:sign_in, :get_lookup_data]

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
    render :json => {:success => "true", :boards => boards, :degrees => degrees, :courses => courses}
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
  def is_questions_exits
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
    if (Quiz.find_by_test_code(test_code).present?)
      render :json => {:success => true}
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
      @user = User.find_by_auth_token(params[:auth_token])
      render :json => {:success => "false", :errors => "authentication failed"} unless @user.present?
    else
      render :json => {:success => "false", :errors => "authentication failed"}
    end
  end

end
