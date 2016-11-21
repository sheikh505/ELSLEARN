class TopicsController < ApplicationController
  load_and_authorize_resource
  before_filter :set_topic, :only=> [:show, :edit, :update, :destroy]
  layout "admin_panel_layout"
  respond_to :html

  def index
    # @topics = Topic.all


    respond_to do |format|

      @topics = Topic.all
      # @topics = Topic.all.paginate(page: params[:page], per_page: 10)
      # respond_with(@topics)
      format.html
      format.json { render json: TopicsDatatable.new(view_context) }
    end
  end

  def show
    respond_with(@topic)
  end

  def new
    @topic = Topic.new
    @topics = []
    respond_with(@topic)
  end

  def fetch_courses
    degree = Degree.find(params[:degree_id])
    @courses = degree.board_degree_assignments.first.courses
    render partial: "fetch_courses"
  end

  def fetch_table
    session[:course_id] = params[:course_id]
    render partial: "fetch_table"
  end

  def fetch_topics
    respond_to do |format|

      format.html
      format.json { render json: TopicsDatatable.new(view_context, session[:course_id]) }
    end
  end

  def edit
    @course = @topic.course
    @topics = Topic.where("course_id = ? AND parent_topic_id is NULL",@course.id).order(:name)
  end

  def create


    @topic = Topic.new(params[:topic])

    @topic.name.upcase!
    @topic.course_id = params[:course]
    @topic.save
    status = params[:status]
    if (status == '1')

      url =  topics_path
    elsif (status == '0')
      @course_id = params[:course]
      @parent_topic_id = params[:topic][:parent_topic_id]
      if @parent_topic_id.eql?("")
        @parent_topic_id = Topic.last.id.to_s
      end
      url =  new_topic_path+"?parent_topic_id="+@parent_topic_id+"&course_id="+@course_id
    end
    redirect_to url
  end

  def update
    params[:topic][:name].upcase!
    @topic.update_attributes(params[:topic])
    @topic.course_id = params[:course]
    @topic.save
    redirect_to topics_path
  end

  def destroy
    check = Topic.where(parent_topic_id: @topic.id)
    if check.empty?
      @topic.destroy
      respond_with(@topic)
    else
      redirect_to topics_path
      flash[:notice] = "Can not delete"
    end
  end

  def get_topics
    @topics = Topic.where("course_id = ? AND parent_topic_id is NULL",params[:course_id]).order(:name)
    render partial: "parent_topic_select"
  end

  private
  def set_topic
    @topic = Topic.find(params[:id])
  end
end
