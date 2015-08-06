module ApplicationHelper
<<<<<<< HEAD
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

  def get_avatar(user_id)
    url = User.find(user_id).avatar.url(:thumb)

    url = '/assets/FB-profile-avatar.jpg' if url.include? 'missing'
    return url
  end

  def show_results_in_membership result_type
    case result_type
      when 0
        "N/A"
      when 1
        "Instant Result after Test"
      when 2
        "Instant Results for MCQs. Detailed Solutions for Structured Questions with reviews and comments from an expert tutor through email."
      when 3
        "Instant Results for MCQs. Written Comments plus Video Reviewsby an expert tutor through email or skype."
    end
  end
=======
>>>>>>> ef4a4c6b4d3def50e66ed05a76b1c0e3147d32f2
end
