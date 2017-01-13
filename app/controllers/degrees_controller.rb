class DegreesController < ApplicationController
  load_and_authorize_resource
  before_filter :set_degree, :only => [:show, :edit, :update, :destroy]
  layout "admin_panel_layout"
  respond_to :html

  def index
    @degrees = Degree.all
    respond_with(@degrees)
  end

  def manage_degrees
    @degrees = Degree.all
    render partial: "manage_degrees"
  end

  def show
    respond_with(@degree)
  end

  def new
    @degree = Degree.new
    @boards = @degree.boards
    render partial: "new"
  end

  def edit

    @boards = @degree.boards
    render partial: "edit"
  end

  def create
    @degree = Degree.new(name: params[:name], enable: params[:enable])
    @degree.name.upcase!
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

    redirect_to action: :manage_degrees

  end

  def update
    params[:name].upcase!

    @degree.update_attributes(name: params[:name], enable: params[:enable])


    if params[:boards] != nil
      boards = params[:boards]
      puts "===================>>>>boards", boards.inspect
      boards.each_with_index do |board, index|
        boards[index] = board.to_i
      end
      puts "===================>>>>boards", boards.inspect

      bdegree = @degree.board_degree_assignments
      if bdegree.any?
        old_boards = bdegree.pluck(:board_id)
        puts "===================>>>>old_boards", old_boards.inspect
        new_boards = boards - old_boards
        puts "===================>>>>new_boards", new_boards.inspect
        if new_boards.any?
          new_boards.each do |new|
            BoardDegreeAssignment.create(:degree_id => @degree.id, :board_id => new)
          end
        end
        delete_boards = old_boards - boards
        puts "===================>>>>delete_boards", delete_boards.inspect
        if delete_boards.any?
          delete_boards.each do |delete|
            bd = BoardDegreeAssignment.where(board_id: delete, degree_id: @degree.id)
            if bd.any?
              bd.destroy_all
            end
          end
        end
      else
        boards.each do |board|
          BoardDegreeAssignment.create(:degree_id => @degree.id, :board_id => board)
        end
      end

      if !@degree.enable and @degree.board_degree_assignments.any?
        course_ids = DegreeCourseAssignment.where(board_degree_assignment_id: @degree.board_degree_assignments.first.id).pluck(:course_id)
        puts "===================>>>>", course_ids.inspect
        Course.where(id: course_ids).update_all(:enable => false)
      end

    else
      @arr = BoardDegreeAssignment.where(degree_id: @degree.id)
      if @arr.any?
        @arr.each do |bDegree|
          bDegree.destroy

        end
      end
    end


    redirect_to action: :manage_degrees
  end

  def destroy
    @degree.destroy
    @degrees = Degree.all
    render partial: "manage_degrees"
  end

  private
    def set_degree
      @degree = Degree.find(params[:id])
    end
end
