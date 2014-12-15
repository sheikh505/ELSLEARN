class BooksController < ApplicationController
  load_and_authorize_resource
  before_filter :set_book, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @books = Book.all
    respond_with(@books)
  end

  def show
    respond_with(@book)
  end

  def new
    @book = Book.new
    respond_with(@book)
  end

  def edit
  end

  def create
    @id = DegreeCourseAssignment.find_by_course_id_and_degree_id(params[:course],params[:degree])
    @id=@id.id;
    @book = Book.new(:name => params[:book][:name],
                     :price => params[:book][:price],
                     :description => params[:book][:description],
                     :degree_course_assignment_id => @id,
                     :avatar => params[:book][:avatar]
    )
    @book.avatar_file_name =(Time.now.to_i).to_s + '_' + @book.avatar_file_name
    @book.save
    redirect_to books_path
  end

  def update
    @book.update_attributes(params[:book])
    respond_with(@book)
  end

  def destroy
    @book.destroy
    respond_with(@book)
  end

  def get_courses
    @courses = []
    id = params[:degree_id]
    list_courses = DegreeCourseAssignment.find_all_by_degree_id(id)

    list_courses.each do |course|
      @courses << Course.find_by_id(course.course_id)
    end


    render :partial => 'tests/courselist'

  end

  private
    def set_book
      @book = Book.find(params[:id])
    end
end
