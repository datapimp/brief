config do
  set(:models => Pathname(File.dirname(__FILE__)).join("models"))
end

define "User Story" do
  meta do
    title
    status :in => %w(draft published)
    epic_title
  end

  content do
    persona "p strong:first-child"
    behavior "p strong:second-child"
    goal "p strong:third-child"
  end

  helpers do
    def defined_helper_method
      true
    end
  end
end

action "custom command" do
  $custom_command = true
end
