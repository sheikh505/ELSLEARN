module UserHelper

  def valid_packages(user_id)
    User.find_by_id(user_id).user_packages.where("validity > ?", Time.now)
  end

end
