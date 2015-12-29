module TopicLinkingsHelper

  def get_topic_name id
    if id.nil?
    return "NIL"
    else
      return Topic.find(id).name
    end
  end

  def get_course_name_tab id
    if id.nil?
      return nil
    else
      Course.find(id).name
    end
  end

end
