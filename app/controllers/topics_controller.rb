class TopicsController < ApplicationController
  load_and_authorize_resource
  before_filter :set_topic, :only=> [:show, :edit, :update, :destroy]
  layout "admin_panel_layout"
  respond_to :html

  def index
    @topics = Topic.all
    respond_with(@topics)
  end


  def show
    respond_with(@topic)
  end

  def new
    @topic = Topic.new

    respond_with(@topic)
  end

  def edit
    @course = @topic.course
  end

  def create

    @topic = Topic.new(params[:topic])
    @topic.name.upcase!
    @topic.course_id = params[:course]
    @topic.save
    redirect_to topics_path
  end

  def update
    params[:topic][:name].upcase!
    @topic.update_attributes(params[:topic])
    @topic.course_id = params[:course]
    @topic.save
    redirect_to topics_path
  end

  def destroy
    @topic.destroy
    respond_with(@topic)
  end

  private
    def set_topic
      @topic = Topic.find(params[:id])
    end
end
