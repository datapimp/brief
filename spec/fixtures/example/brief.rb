config do
  set(:models => Pathname(File.dirname(__FILE__)).join("models"))
  set(:templates => Pathname(File.dirname(__FILE__)).join("templates"))
end

view :table_of_contents do
  doc = Brief::Document.new(docs_path.join("index.md"), document_type: "outline")
  doc && doc.to_model
end

view :custom_aggregator do
  {aggregator:"custom"}
end

define "Release" do
  meta do
    name
  end
end

define "Outline" do
  meta do
    title
  end
end

define "Feature" do
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
    def defined_helper_method
      true
    end

    def custom_action
      true
    end
  end
end
