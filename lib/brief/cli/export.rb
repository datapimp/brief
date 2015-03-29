command 'export' do |c|
  c.syntax = 'brief export PATH [OPTIONS]'
  c.description = 'export the briefcase found in PATH'

  c.option '--presenter-format FORMAT', String, 'Which presenter to use?'
  c.option '--include-schema', 'Include schema information'
  c.option '--include-models', 'Include individual models as well'
  c.option '--include-content', 'Gets passed to the model renderers if present'
  c.option '--include-rendered', 'Gets passed to the model renderers if present'
  c.option '--include-urls', 'Gets passed to the model renderers if present'

  c.action do |args, options|
    options.default(presenter_format: "full_export")

    root = Pathname(args.first)
    briefcase = Brief::Briefcase.new(root: root)
    briefcase.present(options.presenter_format, rendered: options.include_rendered,
                                                content: options.include_content,
                                                urls: options.include_urls,
                                                schema: options.include_schema,
                                                models: options.include_models)

  end
end

