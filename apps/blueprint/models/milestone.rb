class Brief::Apps::Blueprint::Milestone
  include Brief::Model
  include Brief::RemoteSyncing

  defined_in Pathname(__FILE__)

  meta do
    title
    number
    projects
    personas
    due_date
    tags Array
  end

  content do
    title "h1:first-of-type", :hide => true
    paragraph "p:first-of-type"
    paragraphs "p"
    yaml_data "code.yaml:first-of-type", :serialize => :yaml, :hide => true
  end

  actions do
    def publish
      publish_service.publish(self, via: briefcase.settings.try(:tracking_system))
    end

    def sync
      sync_service.sync(self, via: briefcase.settings.try(:tracking_system))
    end
  end
end
