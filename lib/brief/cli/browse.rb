command 'browse apps' do |c|
  c.syntax = "brief browse apps"
  c.description = "browse the available apps"

  c.action do |args, options|
    require 'terminal-table'
    rows = Brief::Apps.app_paths.map do |folder|
      [folder.basename, folder.to_s]
    end

    table = Terminal::Table.new(:rows => rows, :headings => %w(Name Found-In-Path))
    puts table
  end
end

command 'browse documents' do |c|
  c.syntax = 'brief browse documents PATHS [OPTIONS]'
  c.description = 'browse documents in the briefcase path'

  c.option '--presenter-format FORMAT', String, 'Which presenter to use?'
  c.option '--include-urls', 'Gets passed to the model renderers if present'

  c.example "Browsing an arbitrary selection of documents", "brief parse ./blueprint/docs/epics ./blueprint/docs/features --root=./blueprint --format json --include-rendered --include-content"

  c.action do |args, options|
    options.default(root: Pathname(Brief.pwd), output_type: "array")

    o = {
      root: options.root
    }

    o[:config_path] = options.config_path if options.config_path

    briefcase = Brief::Briefcase.new(o)

    args.map! do |arg|
      arg = Pathname(arg)

      if arg.directory?
        Dir[arg.join('**/*')].map {|f| Pathname(f) }
      else
        arg
      end
    end

    args.flatten!

    args.select! {|arg| Brief::Util.ensure_child_path(briefcase.docs_path, arg) }

    model_params = {
      urls: !!options.include_urls,
      content: false,
      rendered: false,
      schema: false,
      models: false
    }

    parsed = args.map do |path|
      Brief::Document.new(path)
        .in_briefcase(briefcase)
        .to_model
        .as_json(model_params)
    end

    if options.output_type == "hash"
      parsed = parsed.inject({}) do |memo, obj|
        path        = obj[:path]
        memo[path]  = obj
        memo
      end
    end

    parsed
  end
end

command "browse projects" do |c|
  c.syntax = "brief browse projects FOLDER"
  c.description = "Lists information about each of the briefcases in FOLDER"

  c.option '--config-filename FILENAME', String, 'Which filename has the briefcase config? default(brief.rb)'
  c.option '--presenter-format FORMAT', String, 'Which presenter to use?'
  c.option '--include-schema', 'Include schema information'
  c.option '--include-models', 'Include individual models as well'
  c.option '--include-content', 'Gets passed to the model renderers if present'
  c.option '--include-rendered', 'Gets passed to the model renderers if present'
  c.option '--include-urls', 'Gets passed to the model renderers if present'

  c.action do |args, options|
    folder = Pathname(args.first)

    options.default(config_filename:'brief.rb', presenter_format: 'default')

    roots = folder.children.select do |root|
      root.join(options.config_filename).exist?
    end

    briefcases = roots.map {|root| Brief::Briefcase.new(root: Pathname(root).realpath) }

    briefcases.map do |b|
      b.present(options.presenter_format, rendered: options.include_rendered,
                                          content: options.include_content,
                                          urls: options.include_urls,
                                          schema: options.include_schema,
                                          models: options.include_models)
    end
  end
end
