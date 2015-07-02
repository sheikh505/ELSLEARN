module ApplicationHelper
  def show_difficulty difficulty
    case difficulty
      when 1
        "Easy"
      when 2
        "Medium"
      when 3
        "Hard"
    end
  end

  def show_status is_approved
    case is_approved
      when true
        "Approved"
      when false
        "Rejected"
    end
  end
end
