class MembershipPlansController < ApplicationController
  before_filter :set_membership_plan, only: [:show, :edit, :update, :destroy]
  layout "admin_panel_layout"
  respond_to :html

  def index
    @membership_plans = MembershipPlan.all
    respond_with(@membership_plans)
  end

  def show
    respond_with(@membership_plan)
  end

  def new
    @membership_plan = MembershipPlan.new
    respond_with(@membership_plan)
  end

  def edit
  end

  def create
    @membership_plan = MembershipPlan.new(params[:membership_plan])
    @membership_plan.save
    respond_with(@membership_plan)
  end

  def update
    @membership_plan.update_attributes(params[:membership_plan])
    respond_with(@membership_plan)
  end

  def destroy
    @membership_plan.destroy
    respond_with(@membership_plan)
  end

  private
    def set_membership_plan
      @membership_plan = MembershipPlan.find(params[:id])
    end
end
