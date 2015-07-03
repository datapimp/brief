class Brief::Apps::Blueprint::Release
  include Brief::Model
  include Brief::RemoteSyncing

  defined_in Pathname(__FILE__)

  meta do
    title
    status
    project
    remote_id
    tags Array
  end

  content do
    paragraph "p:first-of-type"
    paragraphs "p"

    title "h1:first-of-type", :hide => true

    settings "pre[lang='yaml'] code:first-of-type", :serialize => :yaml, :hide => true

    define_section "Features" do
      each("h2").has(:title     => "h2",
                     :paragraph => "p:first-of-type",
                     :components   => "p:first-of-type strong"
                    )
    end
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
