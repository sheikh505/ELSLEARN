class TopicsController < ApplicationController
  before_filter :set_topic, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @topics = Topic.all
    respond_with(@topics)
  end

  def get_courses
    @courses = []
    id = params[:degree_id]
    list_courses = DegreeCourseAssignment.find_all_by_degree_id(id)

    list_courses.each do |course|
      @courses << Course.find_by_id(course.course_id)
    end


    render :partial => 'topics/courselist'

  end


  def show
    respond_with(@topic)
  end

  def new
    @topic = Topic.new
    respond_with(@topic)
  end

  def edit
  end

  def create
    @id = DegreeCourseAssignment.find_by_course_id_and_degree_id(params[:course],params[:degree])
    @id=@id.id

    @topic = Topic.new(params[:topic])
    @topic.degree_course_assignment_id = @id
    @topic.save
    redirect_to topics_path
  end

  def update
    @topic.update_attributes(params[:topic])
    respond_with(@topic)
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
