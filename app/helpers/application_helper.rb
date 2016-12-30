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

  def news_feed
    @news_feed = NewsFeed.last
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
    temp = Role.all.select{|x| x.name.downcase == 'teacher'}
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




  def questions_count
    question_counter = 0
    Question.all.each do |question|
      if question.deleted == false
        question_counter += 1
      end
    end
    return question_counter
  end

  def question_count_proofreader
    if current_user.email == "proofreader1@els.com"
      questions = Question.where("(workflow_state = 'new' or workflow_state is null) AND deleted = 'FALSE'")
    else
      questions = Question.where(:author => User.select("email").where(:role=>current_user.id.to_s), :deleted => false, :workflow_state => ["reviewed_by_proofreader", "accepted", "new"])
    end
    # questions = Question.where(:author => User.select("email").where(:role=>current_user.id.to_s), :deleted => false, :workflow_state => ["reviewed_by_proofreader", "accepted", "new"])
    return questions.size
  end

  def question_count_teacher
    if current_user.teacher_courses.present?
      course_list = current_user.teacher_courses
      course_ids = []
      course_list.each do |course|
        course_ids << course.course_id
      end
      questions = Question.select("questions.*,topics.name as topic_name,courses.name as course_name").
          joins(:topic => :course).
          where("author = ? AND course_id IN (?) AND deleted = 'FALSE'", current_user.email,course_ids)
    else
      questions = Question.where(:id => 0)
    end
    return questions.size
  end

  def approve_question_count_teacher
    if current_user.teacher_courses.present?
      course_list = current_user.teacher_courses
      course_ids = []
      course_list.each do |course|
        course_ids << course.course_id
      end
      questions = Question.select("questions.*").
          joins(:course_linking).
          where("(author != ? AND (course_1  IN (?) OR course_2  IN (?) OR course_3  IN (?) OR course_4  IN (?))and workflow_state IN ('reviewed_by_proofreader', 'being_reviewed') and
                        questions.id NOT IN (SELECT question_id as id FROM question_histories WHERE user_id = ?)) AND deleted = 'FALSE'", current_user.email,course_ids, course_ids, course_ids, course_ids, current_user.id)
    else
      questions = Question.where(:id => 0)
    end
    return questions.size
  end

  def new_students_count_teacher
    return TeacherRequest.where(teacher_token: current_user.teacher_token,status: 'PENDING').count
  end

  def manage_students_count_teacher
    return TeacherRequest.where(teacher_token: current_user.teacher_token,status: 'SUCCESSFUL').count
  end

  def comment_feedback_count_teacher
    return UserTestHistory.where("(teacher_id = ? OR teacher_id = -1) AND reviewed = false AND video_review = false", current_user.id).count
  end

  def video_review_count_teacher
    return UserTestHistory.where("(teacher_id = ? OR teacher_id = -1) AND reviewed = false AND video_review = true", current_user.id).count
  end

  def manage_tests_count_teacher
    return Quiz.where(:user_id => current_user.id).count
  end

  def question_count_operator
    questions = Question.where("author = ? and (workflow_state IN ('', 'new')) AND deleted = 'FALSE'", current_user.email)
    return questions.size
  end

  def question_count_operator_rejected
    questions = Question.where("author = ? AND workflow_state = 'rejected'",current_user.email)
    return questions.size
  end

  def question_count_hod
    if current_user.teacher_courses.present?
      course_list = current_user.teacher_courses
      course_ids = []
      course_list.each do |course|
        course_ids << course.course_id
      end
      questions = Question.select("questions.*,topics.name as topic_name,courses.name as course_name").
          joins(:topic => :course).
          where("workflow_state IN ('reviewed_by_proofreader', 'being_reviewed', 'rejected_by_teacher') and course_id IN (?) AND deleted = 'FALSE'", course_ids).
          order("#{sort_helper}")
    else
      questions = Question.where(:id => 0)
    end

    return questions.size
  end


end
