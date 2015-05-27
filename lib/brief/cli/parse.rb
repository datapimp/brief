command 'parse' do |c|
  c.syntax = 'brief parse PATH [OPTIONS]'
  c.description = 'parse the briefcase path'

  c.option '--presenter-format FORMAT', String, 'Which presenter to use?'
  c.option '--include-content', 'Gets passed to the model renderers if present'
  c.option '--include-rendered', 'Gets passed to the model renderers if present'
  c.option '--include-urls', 'Gets passed to the model renderers if present'

  c.example "Parsing an arbitrary selection of documents", "brief parse ./blueprint/docs/epics ./blueprint/docs/features --root=./blueprint --format json --include-rendered --include-content"

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
    #args.map! {|arg| Brief::Document.new(arg.realpath).in_briefcase(briefcase) }

    model_params = {
      rendered: !!options.include_rendered,
      content: !!options.include_content,
      urls: !!options.include_urls
    }

    parsed = args.map do |path|
      Brief::Document.new(path)
        .in_briefcase(briefcase)
        .to_model
        .as_json(model_params)
    end

    if options.output_type == "hash"
      parsed = parsed.inject({}) do |memo, obj|
        path = obj[:path]
        memo[path] = obj
        memo
      end
    end

    parsed
  end
end
