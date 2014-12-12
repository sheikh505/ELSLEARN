class RolesController < ApplicationController
  before_filter :set_role, only: [:show, :edit, :update, :destroy]

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
    respond_with(@role)
  end

  def update
    @role.update_attributes(params[:role])
    respond_with(@role)
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
