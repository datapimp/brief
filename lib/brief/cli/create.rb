command "create app" do |c|
  c.syntax = "brief create app NAME"
  c.description = "create a new brief app"

  c.option '--clone EXISTING_APP', String, 'Clone an existing app'

  c.action do |args, options|
    name = args.first.to_s
    raise 'Must specify a name for your app' unless name.length > 0

    folder = Brief::Apps.home_apps_path.join(name.downcase)

    if folder.exist?
      raise 'An app with this name already exists'
    end

    FileUtils.mkdir_p(folder)

    if options.clone && Brief::Apps.available?(options.clone.downcase.to_s)
      puts "== Cloning #{ options.clone.downcase }"
      FileUtils.cp_r(Brief::Apps.path_for(options.clone.downcase.to_s), Brief::Apps.home_apps_path.join(name.downcase))
    else
      %w(models examples documentation).each do |subfolder|
        FileUtils.mkdir_p folder.join(subfolder)
      end

      folder.join("config.rb").open("w+") do |fh|
        fh.write("config do\n  set(:documentation_path, File.join(File.dirname(__FILE__),'documentation'))\nend")
      end

      puts "== Created app #{ name }"
    end
  end
end

command "create briefcase" do |c|
  c.syntax = "brief create briefcase PATH"
  c.description = "create a new briefcase"

  c.option '--app APP_NAME', String, 'Use the specified app'
  c.option '--use-local-models', nil, 'When using an app, this option will copy over the models locally instead, so you can customize them.'
  c.option '--force', nil, 'Required if PATH already exists'

  c.action do |args, options|
    arg = args.first || "./briefcase"

    folder = Pathname(arg)

    if !options.force && folder.exist?
      raise 'Folder already exists. Pass --force to continue'
    end

    FileUtils.mkdir_p(folder)

    folder.join("config.rb").open("w+") do |fh|
      fh.write("config do\n  set(:models_path, \"./models\") \nend")
    end

    case
    when options.app && options.use_local_models
      folder.join("brief.rb").open("a") do |fh|
        fh.write "\nuse #{ options.app }"
      end

      models_path = Brief::Apps.path_for(options.app).join("models")
      FileUtils.cp_r(models_path, folder)

    when options.app
      folder.join("brief.rb").open("a") do |fh|
        fh.write "\nuse #{ options.app }"
      end
    end

    %w(docs assets data models).each do |subfolder|
      FileUtils.mkdir_p folder.join(subfolder)
    end

    puts "Created briefcase in #{ folder }"
  end
end
