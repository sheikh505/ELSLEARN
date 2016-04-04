class CourseLinkingsController < ApplicationController
  load_and_authorize_resource
  before_filter :set_course_linking, only: [:show, :edit, :update, :destroy]
  layout "admin_panel_layout"
  respond_to :html

  def index
    @course_linkings = CourseLinking.all
    respond_with(@course_linkings)
  end

  def show
    respond_with(@course_linking)
  end

  def new
    @course_linking = CourseLinking.new
    arr = []
    CourseLinking.all.each do |x|

      arr << x.course_1 unless x.course_1.nil?
      arr << x.course_2 unless x.course_2.nil?
      arr << x.course_3 unless x.course_3.nil?
      arr << x.course_4 unless x.course_4.nil?

    end
    arr.uniq!


    ##################### GCE IGCSE ###################################
    @courses_gce_igcse = BoardDegreeAssignment.where("board_id = ? AND degree_id = ?",Board.find_by_name("GCE").id,Degree.find_by_name("IGCSE").id)
    if !@courses_gce_igcse.nil?
      @courses_gce_igcse = @courses_gce_igcse.first
      @courses_gce_igcse = @courses_gce_igcse.courses.blank? ? [] : @courses_gce_igcse.courses
    end

    ##################### GCE O Levels ###################################

    @courses_gce_o_level = BoardDegreeAssignment.where("board_id = ? AND degree_id = ?",Board.find_by_name("GCE").id,Degree.find_by_name("O LEVEL").id)
    @courses_gce_o_level = @courses_gce_o_level.first
    @courses_gce_o_level = @courses_gce_o_level.courses.blank? ? [] : @courses_gce_o_level.courses

    ##################### GCE A Levels ###################################

    @courses_gce_a_level = BoardDegreeAssignment.where("board_id = ? AND degree_id = ?",Board.find_by_name("GCE").id,Degree.find_by_name("GCE - A & AS LEVEL").id)
    @courses_gce_a_level = @courses_gce_a_level.first
    @courses_gce_a_level = @courses_gce_a_level.courses.blank? ? [] : @courses_gce_a_level.courses
    ##################### GCE A Levels ###################################

    @courses_edexcel_a_level = BoardDegreeAssignment.where("board_id = ? AND degree_id = ?",Board.find_by_name("EDEXCEL").id,Degree.find_by_name("EDEXCEL - A & AS LEVEL").id)
    @courses_edexcel_a_level = @courses_edexcel_a_level.first
    @courses_edexcel_a_level = @courses_edexcel_a_level.courses.blank? ? [] : @courses_edexcel_a_level.courses

    unless arr.blank?
      @courses_gce_igcse = @courses_gce_igcse.reject{|x| arr.include? x.id}
      @courses_gce_o_level = @courses_gce_o_level.reject{|x| arr.include? x.id}
      @courses_gce_a_level = @courses_gce_a_level.reject{|x| arr.include? x.id}
      @courses_edexcel_a_level = @courses_edexcel_a_level.reject{|x| arr.include? x.id}

    end

    respond_with(@course_linking)
  end

  def edit
    arr = []
    CourseLinking.all.each do |x|
      unless @course_linking.id == x.id
        arr << x.course_1 unless x.course_1.nil?
        arr << x.course_2 unless x.course_2.nil?
        arr << x.course_3 unless x.course_3.nil?
        arr << x.course_4 unless x.course_4.nil?
      end
    end
    arr.uniq!

    ##################### GCE IGCSE ###################################
    @courses_gce_igcse = BoardDegreeAssignment.where("board_id = ? AND degree_id = ?",Board.find_by_name("GCE").id,Degree.find_by_name("IGCSE").id)
    @courses_gce_igcse = @courses_gce_igcse.first
    @courses_gce_igcse = @courses_gce_igcse.courses.blank? ? [] : @courses_gce_igcse.courses

    ##################### GCE O Levels ###################################

    @courses_gce_o_level = BoardDegreeAssignment.where("board_id = ? AND degree_id = ?",Board.find_by_name("GCE").id,Degree.find_by_name("O LEVEL").id)
    @courses_gce_o_level = @courses_gce_o_level.first
    @courses_gce_o_level = @courses_gce_o_level.courses.blank? ? [] : @courses_gce_o_level.courses

    ##################### GCE A Levels ###################################

    @courses_gce_a_level = BoardDegreeAssignment.where("board_id = ? AND degree_id = ?",Board.find_by_name("GCE").id,Degree.find_by_name("GCE - A & AS LEVEL").id)
    @courses_gce_a_level = @courses_gce_a_level.first
    @courses_gce_a_level = @courses_gce_a_level.courses.blank? ? [] : @courses_gce_a_level.courses
    ##################### GCE A Levels ###################################

    @courses_edexcel_a_level = BoardDegreeAssignment.where("board_id = ? AND degree_id = ?",Board.find_by_name("EDEXCEL").id,Degree.find_by_name("EDEXCEL - A & AS LEVEL").id)
    @courses_edexcel_a_level = @courses_edexcel_a_level.first
    @courses_edexcel_a_level = @courses_edexcel_a_level.courses.blank? ? [] : @courses_edexcel_a_level.courses

    unless arr.blank?
      @courses_gce_igcse = @courses_gce_igcse.reject{|x| arr.include? x.id}
      @courses_gce_o_level = @courses_gce_o_level.reject{|x| arr.include? x.id}
      @courses_gce_a_level = @courses_gce_a_level.reject{|x| arr.include? x.id}
      @courses_edexcel_a_level = @courses_edexcel_a_level.reject{|x| arr.include? x.id}

    end
  end

  def create
    arr = params[:course_linking].values
    arr = arr.select{|x| x != ""}
    if arr.size == arr.uniq().size
      @course_linking = CourseLinking.new(params[:course_linking])
      @course_linking.save
      redirect_to course_linkings_path
    else
      redirect_to "/course_linkings/new",alert: "DUPLICATE COURSES"
    end
  end

  def update
    @course_linking.update_attributes(params[:course_linking])
    redirect_to course_linkings_path
  end

  def destroy
    @course_linking.destroy
    respond_with(@course_linking)
  end

  private
  def set_course_linking
    @course_linking = CourseLinking.find(params[:id])
  end
end
