class DegreesController < ApplicationController
  load_and_authorize_resource
  before_filter :set_degree, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @degrees = Degree.all
    respond_with(@degrees)
  end

  def show
    respond_with(@degree)
  end

  def new
    @degree = Degree.new
    respond_with(@degree)
  end

  def edit
  end

  def create
    @degree = Degree.new(params[:degree])
    @degree.save
    redirect_to degrees_path
  end

  def update
    @degree.update_attributes(params[:degree])
    redirect_to degrees_path
  end

  def destroy
    @degree.destroy
    respond_with(@degree)
  end

  private
    def set_degree
      @degree = Degree.find(params[:id])
    end
end
