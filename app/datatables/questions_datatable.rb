class QuestionsDatatable
  delegate :raw, :label_tag, :params, :h, :link_to, :best_in_place, to: :@view

  def initialize(view)
    @view = view
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
    if @view.current_user.is_operator?
      questions.each_with_index.map do |question,index|
        [
            question.statement.html_safe,
            link_to("View", ("/questions/#{question.id}?from=operator")),
            "#{label_tag('status', h(question.current_state), :title=>question.comments.to_s, :class=> 'question_status')}",
            if question.workflow_state.blank? || h(question.workflow_state) == "new" || h(question.workflow_state) == "rejected"
              link_to 'Edit',("/questions/#{question.id}/edit")
            else
              h("Approved")
            end

        #number_to_currency(product.price)
        ]
      end
    elsif @view.current_user.is_proofreader?
      questions.each_with_index.map do |question,index|
        [
            question.statement.html_safe,
            link_to("View", ("/questions/#{question.id}?from=proofreader")),
            h(question.current_state),
            if question.workflow_state.blank? || h(question.workflow_state) == "new"
              #link_to "Approve","javascript:void(0);",:id => "approve", :onclick => "approve_question(this,#{question.id})"
              #link_to "Reject","javascript:void(0);",:id => "reject", :onclick => "reject_question(this,#{question.id})"
              "#{link_to 'Approve','javascript:void(0);',:id => 'approve', :onclick => "approve_question(this,#{question.id})"}/#{link_to 'Reject','javascript:void(0);',:id => 'reject', :onclick => "reject_question(this,#{question.id})"}"
            else
              h("Approved")
            end
        ]
      end
    elsif @view.current_user.is_teacher?
      course_id = @view.current_user.teacher_courses.first.course_id
      questions.each_with_index.map do |question,index|
        [
            question.statement.html_safe,
            #best_in_place (question, "topic_name", "as" => "input")
            (best_in_place question, :topic_id, :url => @view.update_topic_questions_path(question.id), :type => :select, :collection => Topic.where(:course_id => course_id).each_with_object({}){ |o,h| h[o.id] = o.name }) +
                " " + raw("<i class='fa fa-pencil-square-o'></i>"),
            link_to("View", ("/questions/#{question.id}?from=teacher")),
            h(question.current_state),
            if question.workflow_state.blank? || h(question.workflow_state) == "reviewed_by_proofreader"
              "#{link_to 'Approve','javascript:void(0);',:id => 'approve', :onclick => "approve_question(this,#{question.id})"}/#{link_to 'Reject','javascript:void(0);',:id => 'reject', :onclick => "reject_question(this,#{question.id})"}"
              # link_to "Approve","javascript:void(0);",:id => "approve", :onclick => "approve_question(this,#{question.id})"
              # link_to "Reject","javascript:void(0);",:id => "reject", :onclick => "reject_question(this,#{question.id})"
            else
              h("Approved")
            end
        ]
      end
    end

  end

  def questions
    if @view.current_user.is_operator?
      @questions ||= fetch_questions_by_operator
    elsif @view.current_user.is_proofreader?
      @questions ||= fetch_questions_by_proofreader
    elsif @view.current_user.is_teacher?
      @questions ||= fetch_questions_by_teacher
    end
  end

  def sort_helper
    columns = %w[statement workflow_state]
    sort = "#{sort_column} #{sort_direction}"
    (params[:iSortingCols].to_i-1).times do |i|
      sort << ", #{columns[params["iSortCol_#{i+1}"].to_i]} #{params["sSortDir_#{i+1}"] == "desc" ? "desc" : "asc"}"
    end
    sort
  end

  def fetch_questions_by_proofreader
    if @view.current_user.email == "proofreader1@els.com"
      questions = Question.where("workflow_state = 'new' or workflow_state is null or workflow_state = ?", "reviewed_by_proofreader").order("#{sort_helper}")
    else
      questions = Question.where(:author => User.select("email").where(:role=>@view.current_user.id.to_s)).order("#{sort_helper}")
    end

    questions = questions.page(page).per_page(per_page)
    if params[:sSearch].present?
      questions = questions.where("LOWER(statement) like LOWER(:search)", :search=> "%#{params[:sSearch]}%")
    end
    questions
  end

  def fetch_questions_by_teacher
    if @view.current_user.teacher_courses.present?
      course_id = @view.current_user.teacher_courses.first.course_id
      questions = Question.select("questions.*,topics.name as topic_name,courses.name as course_name").
                  joins(:topic => :course).
                  where("course_id = ? and workflow_state IN ('reviewed_by_proofreader', 'reviewed_by_teacher')", course_id).
                  order("#{sort_helper}")
    else
      questions = Question.new
    end

    questions = questions.page(page).per_page(per_page)
    if params[:sSearch].present?
      questions = questions.where("LOWER(statement) like LOWER(:search)", :search=> "%#{params[:sSearch]}%")
    end
    questions
  end

  def fetch_questions_by_operator
    questions = Question.where("author = ?", @view.current_user.email).order("#{sort_helper}")
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
