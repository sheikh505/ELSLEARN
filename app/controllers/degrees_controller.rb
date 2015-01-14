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
    @boards = @degree.boards
    respond_with(@degree)
  end

  def edit

    @boards = @degree.boards
    
  end

  def create



    @degree = Degree.new(params[:degree])
     if @degree.save
       params[:boards].each do |board|
         ass = BoardDegreeAssignment.new(:degree_id => @degree.id, :board_id => board)
         ass.save

       end

     end

=begin    degree_id = Degree.find_by_name(params[:degree][:name])

    unless degree_id.nil?
      if BoardDegreeAssignment.find_by_board_id_and_degree_id(params[:board], degree_id).nil?


          @ass = BoardDegreeAssignment.new(:degree_id => degree_id.id, :board_id => params[:board])
          @ass.save

      end

    else
      @degree = Degree.new(params[:degree])
      if @degree.save
        @ass = BoardDegreeAssignment.new(:degree_id => @degree.id, :board_id => params[:board])
        @ass.save
      end

    end
=end

    redirect_to degrees_path

  end

  def update


    @degree.update_attributes(params[:degree])
    if params[:boards] != nil
    board = params[:boards]

    @arr = BoardDegreeAssignment.find_all_by_degree_id(@degree.id)
      if @arr
        @arr.each do |bDegree|
          bDegree.destroy unless board.find {|x| x == bDegree.board_id}

        end
      end



      params[:boards].each do |board|
        unless @arr.find {|x| x.board_id == board }
          ass = BoardDegreeAssignment.new(:degree_id => @degree.id, :board_id => board)
          ass.save
        end

      end
    else
      @arr = BoardDegreeAssignment.find_all_by_degree_id(@degree.id)
      if @arr
        @arr.each do |bDegree|
          bDegree.destroy

        end
      end
    end


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
