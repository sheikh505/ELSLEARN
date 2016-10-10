class Quiz < ActiveRecord::Base
  belongs_to :course
  belongs_to :user
  validates :name, presence: true
  validates :user_id, presence: true
  validates :question_ids, presence: true
  validates :course_id, presence: true
  validates :test_code, presence: true

  default_scope order('quizzes.created_at DESC')
  attr_accessible :name, :question_ids, :test_code, :attempted, :user_id, :course_id
end
