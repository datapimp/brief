command "init" do |c|
  c.syntax = "brief init [OPTIONS]"
  c.description = "Create a new brief project, aka a briefcase"

  c.option "--root", String, "The root folder for the new project."

  c.action do |args, options|

  end
end
