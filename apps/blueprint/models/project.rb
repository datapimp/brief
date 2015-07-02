class Brief::Apps::Blueprint::Project
  include Brief::Model

  defined_in Pathname(__FILE__)

  meta do
    title
    category
    tags Array
  end

  content do
    paragraph "p:first-of-type"
    title "h1:first-of-type", :hide => true
    tagline "h2:first-of-type", :hide => true
    yaml_data "code.yaml:first-of-type", :serialize => :yaml, :hide => true
  end

  actions do
    def publish
      BlueprintProjectPublisher.publish(self, via: briefcase.settings.try(:tracking_system))
    end

    def sync
      BlueprintProjectPublisher.sync(self, via: briefcase.settings.try(:tracking_system))
    end
  end

  def epics
    briefcase.epics(project: title)
  end

  def sitemaps
    briefcase.sitemaps(project: title)
  end

  def features
    briefcase.features(project: title)
  end

  def releases
    briefcase.releases(project: title)
  end
end
