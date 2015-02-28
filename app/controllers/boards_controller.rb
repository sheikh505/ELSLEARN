class BoardsController < ApplicationController
  before_filter :set_board, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @boards = Board.all
    respond_with(@boards)
  end

  def show
    respond_with(@board)
  end

  def new
    @board = Board.new
    respond_with(@board)
  end

  def edit
  end

  def create
    @board = Board.new(params[:board])
    @board.name.upcase!
    @board.save
    redirect_to boards_path
  end

  def update
    params[:board][:name].upcase!
    @board.update_attributes(params[:board])
    respond_with(@board)
  end

  def destroy
    BoardDegreeAssignment.all.each {|bd| bd.destroy if bd.board_id.eql?(@board.id) }
    @board.destroy
    respond_with(@board)
  end

  private
    def set_board
      @board = Board.find(params[:id])
    end
end
