class UserController < ApplicationController
  def new
  end

  def save_result
    @board_id = params[:b_id]
    @degree_id = params[:degree_id]
    @course_id = params[:course_id]
    @mcq = params[:mcq]
    @fill = params[:fill]
    @true_false = params[:true_false]
    @descriptive = params[:descriptive]
    @past_paper_flag = params[:pre_Past]
    @year = params[:year]
    @session = params[:session]
    UserTestHistory.new(params[:user_test_history])
    UserTestHistory.save
    redirect_to root_path
  end

  def my_profile
  end
end
