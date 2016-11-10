class UserPackage < ActiveRecord::Base
  attr_accessible :credit_left, :package_id, :user_id, :validity
end
