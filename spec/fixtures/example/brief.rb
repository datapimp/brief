config do
  set(:models => Pathname(File.dirname(__FILE__)).join("models"))
  set(:templates => Pathname(File.dirname(__FILE__)).join("templates"))
end

define "User Story" do
  meta do
    title
    status :in => %w(draft published)
    epic_title
  end

  template :file => "user_story.md.erb"

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
