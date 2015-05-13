class Question < ActiveRecord::Base
  include Workflow
  workflow do
    state :new do
      event :submit, :transitions_to => :reviewed_by_proofreader
      event :reject, :transitions_to => :rejected
    end
    state :reviewed_by_proofreader do
      event :submit, :transitions_to => :reviewed_by_teacher
      event :reject, :transitions_to => :rejected
    end
    state :rejected do
      event :submit, :transitions_to => :new
    end
    state :reviewed_by_teacher do
      event :submit, :transitions_to => :awaiting_review
    end
    state :awaiting_review do
      event :review, :transitions_to => :being_reviewed
    end
    state :being_reviewed do
      event :accept, :transitions_to => :accepted
      event :reject, :transitions_to => :rejected
    end
    state :accepted
  end

  default_scope order('created_at DESC')
  has_many :options, dependent: :destroy
  belongs_to :topic
  has_one :past_paper_history

  has_many :board_question_assignments
  has_many :board_degree_assignments,through: :board_question_assignments


  attr_accessible :answer, :statement, :description, :test_id, :instruction, :source, :author,
                  :difficulty, :board, :topic_id, :question_type, :deleted, :approval_status



def self.search (search , page, limit)
  unless search.nil?
    self.all.select{|x| x.deleted == false && x.statement.downcase.include?(search.downcase)}.paginate :per_page => limit, :page => page
  else
    self.all.select{|x| x.deleted == false}.paginate :per_page => limit, :page => page
  end
end

  def not_deleted_question?

    if self.deleted == true
     return false
    else
     return true
    end

  end
end
