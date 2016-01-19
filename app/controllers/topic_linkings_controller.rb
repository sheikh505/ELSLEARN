class TopicLinkingsController < ApplicationController
  load_and_authorize_resource
  before_filter :set_topic_linking, only: [:show, :edit, :update, :destroy]
  layout "admin_panel_layout"
  respond_to :html

  def index
    @topic_linkings = TopicLinking.all
    respond_with(@topic_linkings)
  end

  def show
    respond_with(@topic_linking)
  end


  def new
    @topic_linking = TopicLinking.new
    @courses = Course.order(:name)
    @course_arr = []
    @courses.all.each do |course|
      unless CourseLinking.search_on_course_column(course.id).nil?
        @course_arr << course
      end
    end
    respond_with(@topic_linking)
  end


  def edit
    @course_linking = @topic_linking.course_linking
    arr = []
    TopicLinking.all.each do |topic|
      if topic.id != @topic_linking.id
        arr << topic.topic_1 unless topic.topic_1.nil?
        arr << topic.topic_2 unless topic.topic_2.nil?
        arr << topic.topic_3 unless topic.topic_3.nil?
        arr << topic.topic_4 unless topic.topic_4.nil?
      end
    end
    arr.uniq!

    @topics_1 = Topic.where("course_id = ? AND id NOT IN (#{arr.join(",")})",@course_linking.course_1)
    @topics_2 = Topic.where("course_id = ? AND id NOT IN (#{arr.join(",")})",@course_linking.course_2)
    @topics_3 = Topic.where("course_id = ? AND id NOT IN (#{arr.join(",")})",@course_linking.course_3)
    @topics_4 = Topic.where("course_id = ? AND id NOT IN (#{arr.join(",")})",@course_linking.course_4)

  end

  def create
    @flag = true
    @stop_flag = false
    respond_to do |format|
      @direction = params[:direction]
      @topic_linking = TopicLinking.new(params[:topic_linking])
      if @topic_linking.save
        if @direction == "save_next"
          @course_linking = CourseLinking.find(@topic_linking.course_linking_id)
          arr = []
          TopicLinking.all.each do |topic|
            arr << topic.topic_1 unless topic.topic_1.nil?
            arr << topic.topic_2 unless topic.topic_2.nil?
            arr << topic.topic_3 unless topic.topic_3.nil?
            arr << topic.topic_4 unless topic.topic_4.nil?
          end
          arr.uniq!
          @topics_1 = Topic.where("course_id = ? AND id NOT IN (#{arr.join(",")})",@course_linking.course_1)
          @topics_2 = Topic.where("course_id = ? AND id NOT IN (#{arr.join(",")})",@course_linking.course_2)
          @topics_3 = Topic.where("course_id = ? AND id NOT IN (#{arr.join(",")})",@course_linking.course_3)
          @topics_4 = Topic.where("course_id = ? AND id NOT IN (#{arr.join(",")})",@course_linking.course_4)
        else
          @stop_flag = true
        end
      else
        @flag = false
      end
      format.js
    end
  end

  def update
    respond_to do |format|
      @topic_linking.update_attributes(params[:topic_linking])
      format.js
    end
  end

  def destroy
    @topic_linking.destroy
    respond_with(@topic_linking)
  end



  def get_course_link
    respond_to do |format|
      @course_linking = CourseLinking.search_on_course_column(params[:course_id])
      if @course_linking.nil?
        @flag = false
      else
        arr = []
        TopicLinking.all.each do |topic|
          arr << topic.topic_1 unless topic.topic_1.nil?
          arr << topic.topic_2 unless topic.topic_2.nil?
          arr << topic.topic_3 unless topic.topic_3.nil?
          arr << topic.topic_4 unless topic.topic_4.nil?
        end
        arr.uniq!
        if arr.blank?
          @topics_1 = Topic.where("course_id = ?",@course_linking.course_1)
          @topics_2 = Topic.where("course_id = ?",@course_linking.course_2)
          @topics_3 = Topic.where("course_id = ?",@course_linking.course_3)
          @topics_4 = Topic.where("course_id = ?",@course_linking.course_4)
        else
          @topics_1 = Topic.where("course_id = ? AND id NOT IN (#{arr.join(",")})",@course_linking.course_1)
          @topics_2 = Topic.where("course_id = ? AND id NOT IN (#{arr.join(",")})",@course_linking.course_2)
          @topics_3 = Topic.where("course_id = ? AND id NOT IN (#{arr.join(",")})",@course_linking.course_3)
          @topics_4 = Topic.where("course_id = ? AND id NOT IN (#{arr.join(",")})",@course_linking.course_4)
        end

        @flag = true
      end
      format.js
    end
  end

  private
  def set_topic_linking
    @topic_linking = TopicLinking.find(params[:id])
  end
end
