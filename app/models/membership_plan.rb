class MembershipPlan < ActiveRecord::Base
  attr_accessible :max_questions_allowed, :other_course_amount, :paper, :price, :result_type, :validity,:name
  has_many :users
end
