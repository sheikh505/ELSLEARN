module QuestionsHelper

  def get_course_name_tab id
    if id.nil?
      return nil
    else
      Course.find(id).name
    end
  end

  def get_course_board_tab id
    if id.nil?
      return nil
    else
      course = Course.find(id)
      cd_assignment = course.degree_course_assignments.last unless course.nil?
      bd_assignment = cd_assignment.board_degree_assignment unless cd_assignment.nil?
      bd_assignment.nil? ? nil : bd_assignment.board.name
    end
  end

  def get_course_degree_tab id
    if id.nil?
      return nil
    else
      course = Course.find(id)
      cd_assignment = course.degree_course_assignments.last unless course.nil?
      bd_assignment = cd_assignment.board_degree_assignment unless cd_assignment.nil?
      bd_assignment.nil? ? nil : bd_assignment.degree.name
    end
  end

end
