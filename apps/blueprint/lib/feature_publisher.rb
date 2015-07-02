class BlueprintFeaturePublisher
  def self.publish(epic, options={})
    via = (options.fetch(:via, :github) || :github)

    if respond_to?("publish_via_#{via}")
      send("publish_via_#{via}", epic,options)
    else
      raise "Invalid publishing source. Need to implement publish_via_#{via} method"
    end
  end

  def self.sync(epic, options={})
    via = (options.fetch(:via, :github) || :github)

    if respond_to?("sync_via_#{via}")
      send("sync_via_#{via}", epic,options)
    else
      raise "Invalid syncing source. Need to implement sync_via_#{via} method"
    end
  end

  def self.publish_via_pivotal(epic, options={})
    raise "Not Implemented.  Implement #{ name }.publish_via_pivotal"
  end

  def self.publish_via_github(epic, options={})
    raise "Not Implemented.  Implement #{ name }.publish_via_github"
  end
end
