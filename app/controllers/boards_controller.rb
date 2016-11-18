
class BoardsController < ApplicationController
  load_and_authorize_resource
  before_filter :set_board, :only=> [:show, :edit, :update, :destroy]
  layout "admin_panel_layout"
  respond_to :html

  def index
    @boards = Board.all
    respond_with(@boards)
  end

  def manage_boards
    @boards = Board.all
    render partial: "manage_boards"
  end

  def show
    respond_with(@board)
  end

  def new
    @board = Board.new
    render partial: "new"
  end

  def edit
    render partial: "edit"
  end

  def create
    @board = Board.new(name: params[:name], enable: params[:enable])
    @board.name.upcase!
    @board.save
    redirect_to action: :manage_boards
  end

  def update
    params[:name].upcase!
    @board.update_attributes(name: params[:name], enable: params[:enable])
    redirect_to action: :manage_boards
  end

  def destroy
    BoardDegreeAssignment.all.each {|bd| bd.destroy if bd.board_id.eql?(@board.id) }
    @board.destroy
    @boards = Board.all
    render partial: "manage_boards"
  end

  private
    def set_board
      @board = Board.find(params[:id])
    end
end
