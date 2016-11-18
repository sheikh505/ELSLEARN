class QuestionsDatatable
  delegate :raw, :label_tag, :params, :h, :link_to, :best_in_place, :to=> :@view


  def initialize(view,teacher_self_flag = false, course_id = Course.first.id)
    @view = view
    @teacher_self_flag = teacher_self_flag

    @course_linking_id = CourseLinking.where("course_1 = ? OR course_2 = ? OR course_3 = ? OR course_4 = ?", course_id,
                                             course_id, course_id, course_id)
  end

  def as_json(options = {})
    {
        :sEcho=> params[:sEcho].to_i,
        :iTotalRecords=> questions.count,
        :iTotalDisplayRecords=> questions.total_entries,
        :aaData=> data
    }
  end

  private
  def data
    # puts "===================================================>" + questions.inspect
    questions.each_with_index.map do |question,index|
      [
          question.statement,
          link_to("View", ("/questions/#{question.id}")),
          "#{label_tag('status', h(question.current_state), :title=>question.comments.to_s, :class=> 'question_status')}"
      ]

    end
  end

  def questions
    if @view.current_user.is_admin?
      @questions ||= fetch_questions
    elsif @view.current_user.is_operator?
      @questions ||= fetch_questions_by_operator
    elsif @view.current_user.is_proofreader?
      @questions ||= fetch_questions_by_proofreader
    elsif @view.current_user.is_teacher?
      if @teacher_self_flag == '1' # teacher's questions only
        @questions ||= fetch_questions_by_teacher_self
      else                      # all un approved questions only
        @questions ||= fetch_questions_by_teacher
      end
      @questions ||= fetch_questions_by_teacher
    elsif @view.current_user.is_hod?
      @questions ||= fetch_questions_by_hod
    end
  end

  def sort_helper
    columns = %w[statement]
    sort = "#{sort_column} #{sort_direction}"
    (params[:iSortingCols].to_i-1).times do |i|
      sort << ", #{columns[params["iSortCol_#{i+1}"].to_i]} #{params["sSortDir_#{i+1}"] == "desc" ? "desc" : "asc"}"
    end
    sort
  end

  def fetch_questions
      questions = Question.where("id > 0 AND deleted = 'FALSE' AND course_linking_id = ?", @course_linking_id).order("#{sort_helper}")
      questions = questions.page(page).per_page(per_page)
    if params[:sSearch].present?
      questions = questions.where("LOWER(statement) like LOWER(:search)", :search=> "%#{params[:sSearch]}%")
    end
    questions
  end

  def fetch_questions_by_proofreader
    if @view.current_user.email == "proofreader1@els.com"
      questions = Question.where("(workflow_state = 'new' or workflow_state is null) AND deleted = 'FALSE'").order("#{sort_helper}")
    else
      questions = Question.where(:author => User.select("email").where(:role=>@view.current_user.id.to_s), :deleted => false, :workflow_state => ["new"]).order("#{sort_helper}")
    end

    questions = questions.page(page).per_page(per_page)
    if params[:sSearch].present?
      questions = questions.where("LOWER(statement) like LOWER(:search)", :search=> "%#{params[:sSearch]}%")
    end
    questions
  end

  def fetch_questions_by_teacher
    if @view.current_user.teacher_courses.present?
      course_list = @view.current_user.teacher_courses
      course_ids = []
      course_list.each do |course|
        course_ids << course.course_id
      end
      questions = Question.select("questions.*").
                  joins(:course_linking).
                  where("(author != ? AND (course_1  IN (?) OR course_2  IN (?) OR course_3  IN (?) OR course_4  IN (?))and workflow_state IN ('reviewed_by_proofreader', 'being_reviewed') and
                        questions.id NOT IN (SELECT question_id as id FROM question_histories WHERE user_id = ?)) AND deleted = 'FALSE'", @view.current_user.email,course_ids, course_ids, course_ids, course_ids, @view.current_user.id).
                  order("#{sort_helper}")
    else
      questions = Question.where(:id => 0)
    end
    questions = questions.page(page).per_page(per_page)
    if params[:sSearch].present?
      questions = questions.where("LOWER(statement) like LOWER(:search)", :search=> "%#{params[:sSearch]}%")
    end
    questions
  end

  def fetch_questions_by_teacher_self
    if @view.current_user.teacher_courses.present?
      course_list = @view.current_user.teacher_courses
      course_ids = []
      course_list.each do |course|
        course_ids << course.course_id
      end
      questions = Question.select("questions.*,topics.name as topic_name,courses.name as course_name").
          joins(:topic => :course).
          where("author = ? AND course_id IN (?) AND deleted = 'FALSE'", @view.current_user.email,course_ids).
          order("#{sort_helper}")
    else
      questions = Question.where(:id => 0)
    end
    questions = questions.page(page).per_page(per_page)
    if params[:sSearch].present?
      questions = questions.where("LOWER(statement) like LOWER(:search)", :search=> "%#{params[:sSearch]}%")
    end
    questions
  end

  def fetch_questions_by_hod
    if @view.current_user.teacher_courses.present?
      course_list = @view.current_user.teacher_courses
      course_ids = []
      course_list.each do |course|
        course_ids << course.course_id
      end
      questions = Question.select("questions.*")
          .joins(:course_linking).
          where("(course_1  IN (?) OR course_2  IN (?) OR course_3  IN (?) OR course_4  IN (?))
                  AND workflow_state IN ('reviewed_by_proofreader', 'being_reviewed', 'rejected_by_teacher', 'pending_for_hod_approval') AND deleted = 'FALSE'",
                  course_ids, course_ids, course_ids, course_ids).
          order("#{sort_helper}")
    else
      questions = Question.where(:id => 0)
    end

    questions = questions.page(page).per_page(per_page)
    if params[:sSearch].present?
      questions = questions.where("LOWER(statement) like LOWER(:search)", :search=> "%#{params[:sSearch]}%")
    end
    questions
  end

  def fetch_questions_by_operator
    questions = Question.where("author = ? and (workflow_state IN ('', 'new')) AND deleted = 'FALSE'", @view.current_user.email).order("#{sort_helper}")
    questions = questions.page(page).per_page(per_page)
    if params[:sSearch].present?
      questions = questions.where("LOWER(statement) like LOWER(:search)", :search=> "%#{params[:sSearch]}%")
    end
    questions
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns = %w[statement workflow_state]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end

  def self.test_values
    ['Asian', 'Latin-Hispanic', 'Caucasian']
  end
end
