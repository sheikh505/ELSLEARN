class UserController < ApplicationController
  def new
  end

  def save_result
    if params[:user_test_history][:id].to_i == 0
      user_history = UserTestHistory.new(params[:user_test_history])
      user_history.save
    else
      UserTestHistory.find(params[:user_test_history][:id]).update_attributes(params[:user_test_history])
    end
    redirect_to user_dashboard_path
  end

  def my_profile
    @user = User.find(current_user.id)
    @last_user_history = UserTestHistory.find_all_by_user_id(@user.id).last
  end
  def update
    @user = User.find current_user.id

    respond_to do |format|
      if @user.update_attributes(params[:user])
        format.html { redirect_to(:controller =>"user", :action=>"my_profile", :notice => 'User was successfully updated.') }
        format.json { respond_with_bip(@user) }
      else
        format.html { render :action => "edit" }
        format.json { respond_with_bip(@user) }
      end
    end
  end

  def update_password
    @user = User.find(current_user.id)
    respond_to do |format|
      if @user.update_with_password(params[:user])
        # Sign in the user by passing validation in case their password changed
        sign_in @user, :bypass => true
        format.html { redirect_to(:controller =>"user", :action=>"my_profile", :notice => 'User was successfully updated.') }
        format.json { respond_with_bip(@user) }
      else
        format.html { redirect_to(:controller =>"user", :action=>"my_profile", :notice => @user.errors.full_messages) }
        format.json { respond_with_bip(@user) }
      end
    end
  end

  def dashboard
    @user = User.find(current_user.id)
    @user_test_histories = UserTestHistory.find_all_by_user_id(@user.id)
  end

  def ReTakeTest
    user_test_history_id = params[:user_test_history_id]
    @user_test_histories = UserTestHistory.find(user_test_history_id)
    redirect_to :action => 'quiz', :controller => "home_page", :user_test_history_id=>user_test_history_id
    # :b_id=> @user_test_histories[:board_id],
    # :degree_id=> @user_test_histories[:degree_id],
    # :course_id=> @user_test_histories[:course],:mcq=> @user_test_histories[:mcq],
    # :true_false=> @user_test_histories[:truefalse],:fill=> @user_test_histories[:fill],
    # :descriptive=> @user_test_histories[:descriptive], :pre_Past=> @user_test_histories[:pastpaperflag],
    # :year=> @user_test_histories[:year], :session=> @user_test_histories[:session]
  end
  private

  def user_params
    # NOTE: Using `strong_parameters` gem
    params.required(:user).permit(:password, :password_confirmation)
  end


end
