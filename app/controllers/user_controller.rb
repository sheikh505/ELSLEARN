class UserController < ApplicationController
  def new
  end

  def save_result
    user_history = UserTestHistory.new(params[:user_test_history])
    user_history.save
    redirect_to user_my_profile_path
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
  def dashboard
    @user = User.find(current_user.id)
    @user_test_histories = UserTestHistory.find_all_by_user_id(@user.id)
  end
end
