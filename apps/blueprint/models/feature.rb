class Brief::Apps::Blueprint::Feature
  include Brief::Model

  defined_in Pathname(__FILE__)

  meta do
    title
    status :in => %w(draft published)
    epic_title
  end

  template :file => "feature.md.erb"

  content do
    persona "p strong:first-child"
    behavior "p strong:second-child"
    goal "p strong:third-child"
  end

  actions do
    def sync_with_github
    end
  end
end
