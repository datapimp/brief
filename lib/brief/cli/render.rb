command 'render' do |c|
  c.syntax = 'brief render PATH [OPTIONS]'
  c.description = 'render the briefcase path'

  c.option '--root PATH', String, 'The briefcase root'
  c.option '--output PATH', String, 'Save the output to the specified path'
  c.option '--app APP', String, 'Use the specified app to get our models etc'
  c.option '--config PATH', String, 'Use the specified config file'
  c.option '--include-raw', nil, 'Whether or not to include the raw content'
  c.option '--type STRING', String, 'What type of document should this be?'
  c.option '--all', 'Render all of the things'

  c.action do |args, options|
    options.default(root: Pathname(Brief.pwd))

    o = {
      root: options.root
    }

    o[:app] = options.app if options.app
    o[:config_path] = options.config if options.config

    briefcase = Brief::Briefcase.new(o)

    index = 0

    rendered = if options.all
      briefcase.all_models.map do |model|
        model.document.to_html(script: true, content: !!(options.include_raw), skip_preamble: (index += 1) > 1)
      end
    elsif args.empty? && stdin = STDIN.read
      stdin
    else
      args.map do |a|
        Dir[briefcase.root.join(a)].map do |f|
          doc = Brief::Document.new(f).in_briefcase(briefcase)
          doc.to_html(script: true, content: !!(options.include_raw), skip_preamble: (index += 1) > 1)
        end
      end.flatten
    end

    html = rendered.join("\n")
    html = "<html><head></head><body class='brief-export #{options[:app]}'>#{html}</body></html>"
    if options.output
      Pathname(options.output).open("w+") do |fh|
        fh.write(html)
      end
    else
      puts html
    end
  end
end

command 'render view' do |c|
  c.syntax = 'brief render view VIEW [OPTIONS]'
  c.description = 'render one of the defined views of the briefcase'

  c.option '--include-schema', 'Include schema information'
  c.option '--include-models', 'Include individual models as well'
  c.option '--include-data', 'Gets passed to the model renderers if present'
  c.option '--include-content', 'Gets passed to the model renderers if present'
  c.option '--include-rendered', 'Gets passed to the model renderers if present'
  c.option '--include-attachments', 'Gets passed to the model renderers if present'
  c.option '--include-urls', 'Gets passed to the model renderers if present'

  c.action do |args, options|
    view = args.first || :full_export

    options.default(root: Pathname(Brief.pwd))

    briefcase = Brief.case = Brief::Briefcase.new(root: Pathname(options.root))

    briefcase.present(view, rendered: options.include_rendered,
                            content: options.include_content,
                            urls: options.include_urls,
                            schema: options.include_schema,
                            data: options.include_data,
                            attachments: options.include_attachments,
                            models: options.include_models)

  end
end
