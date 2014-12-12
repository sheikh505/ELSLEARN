class UserAddress < ActiveRecord::Base
  belongs_to :user
  attr_accessible :address, :city, :coutry, :state, :zipcode
end
