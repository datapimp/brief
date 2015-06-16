class Brief::Apps::Blueprint::Feature
  include Brief::Model

  defined_in Pathname(__FILE__)

  meta do
    title
    project
    owner
    status :in => %w(draft published)
    persona
    goal
    behavior
    epic_title
    remote_id
  end

  template :file => "feature.md.erb"

  content do
    persona "p strong:first-child"
    behavior "p strong:second-child"
    goal "p strong:third-child"
    settings "pre[lang='yaml'] code:first-of-type", :serialize => :yaml, :hide => true
  end

  actions do
    def sync_with_github
    end
  end
end
