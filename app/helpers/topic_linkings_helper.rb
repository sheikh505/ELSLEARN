module TopicLinkingsHelper
  def get_topic_name id
    if (id.nil? || Topic.find_by_id(id).nil?)
      return "NIL"
    else
      return Topic.find_by_id(id).name
    end
  end

  def get_course_name_tab id
    if (id.nil? || Course.find_by_id(id).nil?)
      return "NIL"
    else
      Course.find_by_id(id).name
    end
  end

end
