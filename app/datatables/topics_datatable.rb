

class TopicsDatatable < ApplicationController
  delegate :params, :h, :link_to, :number_to_currency, to: :@view

  def initialize(view, course_id = Course.first.id)
    @view = view
    @course_id = course_id
  end

  def as_json(options = {})
    {
        sEcho: params[:sEcho].to_i,
        iTotalRecords: topics.count,
        iTotalDisplayRecords: topics.total_entries,
        aaData: data
    }
  end

  private


  def data

    puts "==============================>>" + topics.inspect
    topics.map do |topic|
      [

          # topic.ge
          h(topic.name),
          # h(topic.category),
          # h(topic.parent_topic_id)
          h(get_parent_topic_name(topic.parent_topic_id)),
          h(Course.find_by_id(topic.course_id).name),
          link_to('Edit', :controller => 'topics', :action => 'edit', :id => topic) + "/ " +link_to('Destroy', topic, method: :delete, data: { confirm: 'Are you sure?' })
          # h(topic.released_on.strftime("%B %e, %Y")),
          # number_to_currency(topic.price)
      ]
    end
  end

  def topics
    @topics ||= fetch_topics
  end

  def get_parent_topic_name(topic_id)
    topic_id.nil? ? "":Topic.find(topic_id).name
  end

  def fetch_topics
    topics = Topic.where(course_id: @course_id)
    topics = topics.order("#{sort_column} #{sort_direction}")
    topics = topics.page(page).per_page(per_page)
    if params[:sSearch].present?
      # topics = topics.where("name like :search or parent_topic_id like :search", search: "%#{params[:sSearch]}%")
      topics = topics.where("LOWER(name) like LOWER(:search)", :search=> "%#{params[:sSearch]}%")
    end
    topics
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    # columns = %w[name category released_on price]
    columns = %w[name parent_topic_id course_id]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end

