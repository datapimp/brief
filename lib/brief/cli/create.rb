command "create app" do |c|
  c.syntax = "brief create app NAME"
  c.description = "create a new brief app"

  c.option '--clone EXISTING_APP', String, 'Clone an existing app'

  c.action do |args, options|
    name = args.first
  end
end

command "create briefcase" do |c|
  c.syntax = "brief create app PATH"
  c.description = "create a new briefcase"

  c.option '--app APP_NAME', String, 'Use the specified app'
  c.option '--use-local-models', nil, 'When using an app, this option will copy over the models locally instead, so you can customize them.'

  c.action do |args, options|
  end
end
