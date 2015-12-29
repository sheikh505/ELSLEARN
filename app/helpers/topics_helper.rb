module TopicsHelper
  def get_parent_topic_name(topic_id)

      topic_id.nil? ? "":Topic.find(topic_id).name

  end
end
