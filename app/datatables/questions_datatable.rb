class QuestionsDatatable
  delegate :params, :h, :link_to, :number_to_currency, to: :@view

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
        :sEcho=> params[:sEcho].to_i,
        :iTotalRecords=> Question.count,
        :iTotalDisplayRecords=> questions.total_entries,
        :aaData=> data
    }
  end

  private
  def data
    questions.each_with_index.map do |question,index|
      [
          question.statement.html_safe,
          link_to("View", ("/questions/#{question.id}?from=proofreader")),
          h(question.current_state),
          if question.workflow_state.blank? || h(question.workflow_state) == "new"
            link_to "Approve","javascript:void(0);",:id => "approve", :onclick => "approve_question(this,#{question.id})"
          else
            h("Approved")
          end

          #number_to_currency(product.price)
      ]
    end
  end

  def questions
    @questions ||= fetch_questions
  end

  def sort_helper
    columns = %w[statement workflow_state]
    sort = "#{sort_column} #{sort_direction}"
    (params[:iSortingCols].to_i-1).times do |i|
      sort << ", #{columns[params["iSortCol_#{i+1}"].to_i]} #{params["sSortDir_#{i+1}"] == "desc" ? "desc" : "asc"}"
    end
    sort
  end

  def fetch_questions
    questions = Question.where("workflow_state = 'new' or workflow_state is null or workflow_state = ?", "reviewed_by_proofreader").order("#{sort_helper}")

    questions = questions.page(page).per_page(per_page)
    if params[:sSearch].present?
      questions = questions.where("statement like :search", :search=> "%#{params[:sSearch]}%")
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
end
