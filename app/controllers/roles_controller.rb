class RolesController < ApplicationController
  load_and_authorize_resource
  before_filter :set_role, :only=> [:show, :edit, :update, :destroy]
  layout "admin_panel_layout"
  respond_to :html

  def index
    @roles = Role.all
    respond_with(@roles)
  end

  def show
    respond_with(@role)
  end

  def new
    @role = Role.new
    respond_with(@role)
  end

  def edit
  end

  def create
    @role = Role.new(params[:role])
    @role.save
    redirect_to roles_path
  end

  def update
    @role.update_attributes(params[:role])
    redirect_to roles_path
  end

  def destroy
    @role.destroy
    respond_with(@role)
  end

  private
    def set_role
      @role = Role.find(params[:id])
    end
end
