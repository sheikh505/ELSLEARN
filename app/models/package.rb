class Package < ActiveRecord::Base
  has_many :user_packages, dependent: :delete_all

  attr_accessible :name, :price, :flag, :degree_id, :mcq, :fill, :true_false, :descriptive, :past_paper, :instant_result, :teacher_review, :video_review
end
