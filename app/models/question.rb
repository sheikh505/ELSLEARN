class Question < ActiveRecord::Base
  has_many :options, dependent: :destroy
  belongs_to :topic
  has_one :past_paper_history

  has_many :board_question_assignments
  has_many :board_degree_assignments,through: :board_question_assignments


  attr_accessible :answer, :statement, :description, :test_id, :instruction, :source, :author, :difficulty, :board, :topic_id, :question_type, :deleted



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
