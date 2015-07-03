class Brief::Apps::Blueprint::Feature
  include Brief::Model
  include Brief::RemoteSyncing

  defined_in Pathname(__FILE__)

  meta do
    title
    project
    owner
    status :in => %w(draft published)
    persona
    goal
    behavior
    epic
    remote_id
    tags Array
  end

  template :file => "feature.md.erb"

  content do
    persona "p strong:first-child"
    behavior "p strong:second-child"
    goal "p strong:third-child"
    settings "pre[lang='yaml'] code:first-of-type", :serialize => :yaml, :hide => true
  end

  actions do
    def publish
      publish_service.publish(self, via: briefcase.settings.try(:tracking_system))
    end

    def sync
      sync_service.sync(self, via: briefcase.settings.try(:tracking_system))
    end
  end

  helpers do
    def parent_epic
      briefcase.epics(title: epic, project: data.project).first
    end
  end
end
