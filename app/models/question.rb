class Question < ActiveRecord::Base
  include Workflow
  workflow do
    state :new do
      event :submit, :transitions_to => :reviewed_by_proofreader
      event :reject, :transitions_to => :rejected
      event :accept, :transitions_to => :pending_for_hod_approval
    end
    state :reviewed_by_proofreader do
      event :submit, :transitions_to => :being_reviewed
      event :accept, :transitions_to => :accepted
      event :reject, :transitions_to => :rejected_by_teacher
    end
    state :rejected do
      event :submit, :transitions_to => :new
      event :accept, :transitions_to => :accepted
    end
    state :rejected_by_teacher do
      event :submit, :transitions_to => :being_reviewed
      event :accept, :transitions_to => :accepted
    end
    state :pending_for_hod_approval do
      event :submit, :transitions_to => :accepted
      event :accept, :transitions_to => :accepted
      event :reject, :transitions_to => :rejected
    end
    state :being_reviewed do
      event :accept, :transitions_to => :accepted
      event :reject, :transitions_to => :rejected_by_teacher
      event :submitToHOD, :transitions_to => :pending_for_hod_approval
    end
    state :accepted do
      event :reject, :transitions_to => :being_reviewed
    end
  end

  default_scope order('questions.created_at DESC')
  has_many :options, dependent: :destroy
  belongs_to :topic
  has_one :past_paper_history

  has_many :board_question_assignments
  has_many :board_degree_assignments,through: :board_question_assignments
  has_many :question_histories
  belongs_to :course_linking

  attr_accessible :answer, :statement, :description, :test_id, :instruction, :source, :author, :comments, :marks,
                  :difficulty, :board, :topic_id, :question_type, :deleted, :approval_status, :workflow_state,:topic_ids,
                  :difficulty_ids, :degree_ids



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
