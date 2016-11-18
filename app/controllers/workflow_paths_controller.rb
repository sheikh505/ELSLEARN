class WorkflowPathsController < ApplicationController
  layout "admin_panel_layout"
  def index
    @course_degree_hash = {}
    @degrees = Degree.all
    @degree_course_assignment = @degrees.first.board_degree_assignments.first.degree_course_assignments
    @degree_course_assignment.each do |dc|
        unless dc.board_degree_assignment.blank? || dc.board_degree_assignment.degree.blank? || dc.course.blank?
        @course_degree_hash["#{dc.board_degree_assignment.degree.id}_#{dc.board_degree_assignment.degree.name}_#{dc.course.id}"] = dc.course
      end
    end

  end

  def fetch_reviews
    @course_degree_hash = {}
    @degrees = Degree.find(params[:degree_id])
    @degree_course_assignment = @degrees.board_degree_assignments.first.degree_course_assignments
    @degree_course_assignment.each do |dc|
      unless dc.board_degree_assignment.blank? || dc.board_degree_assignment.degree.blank? || dc.course.blank?
        @course_degree_hash["#{dc.board_degree_assignment.degree.id}_#{dc.board_degree_assignment.degree.name}_#{dc.course.id}"] = dc.course
      end
    end
    render partial: "fetch_reviews"
  end

  def toggle_workflow
    workflow_arr = WorkflowPath.where(course_id: params[:course_id],degree_id: params[:degree_id])
    if workflow_arr.blank?
      @workflow_path = WorkflowPath.create(course_id: params[:course_id],degree_id: params[:degree_id],is_complete: params[:value])
    else
      workflow_arr.first.update_attribute(:is_complete, params[:value])
    end
    render :text => 'DONE'
  end
end
