# The BlueprintEpicPublisher
# is an adapter class which will route
# the epic to an API integration capable of
# publishign the epic, such as pivotal tracker or github
class BlueprintEpicPublisher
  def self.publish(epic, options={})
    via = (options.fetch(:via, :github) || :github)

    if respond_to?("publish_via_#{via}")
      send("publish_via_#{via}", epic,options)
    else
      raise "Invalid publishing source. Need to implement publish_via_#{via} method"
    end
  end

  def self.syn(epic, options={})
    via = (options.fetch(:via, :github) || :github)

    if respond_to?("sync_via_#{via}")
      send("sync_via_#{via}", epic,options)
    else
      raise "Invalid syncing source. Need to implement sync_via_#{via} method"
    end
  end


  # Epics get published to Pivotal
  # directly as epics, since Epics have first class support in pivotal
  def self.publish_via_pivotal(epic, options={})
    raise 'This is not implemented in the app yet.  You can implement it on your own by implementing BlueprintEpicPublisher.publish_via_pivotal'
  end

  # Epics get published to Github
  # as issues, and then get labeled as epics.
  # epics will reference other issues.
  def self.publish_via_github(epic, options={})
    raise 'This is not implemented in the app yet.  You can implement it on your own by implementing BlueprintEpicPublisher.publish_via_github'
  end
end
