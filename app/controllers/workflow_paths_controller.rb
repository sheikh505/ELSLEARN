class WorkflowPathsController < ApplicationController
  layout "admin_panel_layout"
  def index
    @course_degree_hash = {}
    @degree_course_assignment = DegreeCourseAssignment.all
      @degree_course_assignment.each do |dc|
          unless dc.board_degree_assignment.blank? || dc.board_degree_assignment.degree.blank? || dc.course.blank?
          @course_degree_hash["#{dc.board_degree_assignment.degree.id}_#{dc.board_degree_assignment.degree.name}_#{dc.course.id}"] = dc.course
        end
      end

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
