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

  def get_avatar(user_id)
    url = User.find(user_id).avatar.url(:thumb)

    url = '/assets/FB-profile-avatar.jpg' if url.include? 'missing'
    return url
  end

  def get_degrees
    return Degree.order(:name)
  end

  def get_courses
    return Course.order(:name)
  end

  def get_student_role
    temp = Role.all.select{|x| x.name.downcase == 'student'}
    return temp.blank? ? nil : temp.first.id
  end

  def get_visiting_teacher_role
    temp = Role.all.select{|x| x.name.downcase == 'visiting'}
    return temp.blank? ? nil : temp.first.id
  end

  def get_institute_role
    temp = Role.all.select{|x| x.name.downcase == 'institute'}
    return temp.blank? ? nil : temp.first.id
  end

  def get_student_stats user
    stats = {}
    stats['flag'] = user.membership_plan.nil? ? false : true
    if stats["flag"] == true
      stats["total_ques"] = user.membership_plan.max_questions_allowed
      stats["ques_attempt"] = 0
      user.user_test_histories.each do |history|
        stats["ques_attempt"] += history.mcq.to_i
        stats["ques_attempt"] += history.fill.to_i
        stats["ques_attempt"] += history.truefalse.to_i
        stats["ques_attempt"] += history.descriptive.to_i
      end
    end
    return stats
  end
end
