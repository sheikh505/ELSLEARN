module CourseLinkingsHelper

  def get_course_name id
    if id.nil?
      return "NIL"
    else
      Course.find(id).name
    end
  end

end
