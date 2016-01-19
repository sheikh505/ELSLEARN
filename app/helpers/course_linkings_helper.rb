module CourseLinkingsHelper

  def get_course_name id
    if (id.nil? || Course.find_by_id(id).nil?)
      return "NIL"
    else
      Course.find_by_id(id).name
    end
  end

end
