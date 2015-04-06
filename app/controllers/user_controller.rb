class UserController < ApplicationController
  def new
  end

  def save_result
    user_history = UserTestHistory.new(params[:user_test_history])
    user_history.save
    redirect_to user_my_profile_path
  end

  def my_profile
  end
end
