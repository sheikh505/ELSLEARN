class Board < ActiveRecord::Base
  has_many :board_degree_assignment
  has_many :degrees, through: :board_degree_assignment
  attr_accessible :name
  validates :name, :uniqueness => true

  def board_degree_hash

    @board_degree_hash = Hash.new

    Board.all.each do |board|
     @board_degree_hash[board.id.to_s + '-' + board.name] = board.degrees
    end
    return @board_degree_hash
  end

end
