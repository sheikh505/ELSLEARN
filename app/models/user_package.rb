class UserPackage < ActiveRecord::Base
  belongs_to :user
  belongs_to :package

  attr_accessible :credit_left, :package_id, :user_id, :validity
end
