command 'dispatch export' do |c|
  c.syntax = 'brief dispatch export PATH [OPTIONS]'
  c.description = 'dispatch the export the briefcase found in PATH'

  c.option '--presenter-format FORMAT', String, 'Which presenter to use?'
  c.option '--include-schema', 'Include schema information'
  c.option '--include-models', 'Include individual models as well'
  c.option '--include-data', 'Gets passed to the model renderers if present'
  c.option '--include-content', 'Gets passed to the model renderers if present'
  c.option '--include-rendered', 'Gets passed to the model renderers if present'
  c.option '--include-attachments', 'Gets passed to the model renderers if present'
  c.option '--include-urls', 'Gets passed to the model renderers if present'
  c.option '--gateway', 'The remote server is a gateway'
  c.option '--port DRB_PORT', String, 'The DRb port to use'
  c.option '--briefcase KEY', String, 'Which briefcase should we use? if this is a gateway'
  c.option '--output FILE', String, 'Save the output in the specified path'
  c.option '--format FORMAT', String, 'How to format the CLI output: defaults to printed, accepts printed,json'
  c.option '--prefix-output CONTENT', String, 'Prefix the generated output with the following content'

  c.when_called do |args, options|
    require 'drb'
    options.default(:port => 9000, briefcase: Pathname(Brief.pwd).dirname.to_s)

    remote = DRbObject.new(nil, "druby://:#{ options.port }")

    if options.gateway
      remote = remote.briefcases[options.briefcase]
    end

    result = remote.present(options.presenter_format, rendered: options.include_rendered,
                                             content: options.include_content,
                                             urls: options.include_urls,
                                             schema: options.include_schema,
                                             data: options.include_data,
                                             attachments: options.include_attachments,
                                             models: options.include_models).as_json
  end
end

command 'export' do |c|
  c.syntax = 'brief export PATH [OPTIONS]'
  c.description = 'export the briefcase found in PATH'

  c.option '--presenter-format FORMAT', String, 'Which presenter to use?'
  c.option '--include-schema', 'Include schema information'
  c.option '--include-models', 'Include individual models as well'
  c.option '--include-data', 'Gets passed to the model renderers if present'
  c.option '--include-content', 'Gets passed to the model renderers if present'
  c.option '--include-rendered', 'Gets passed to the model renderers if present'
  c.option '--include-attachments', 'Gets passed to the model renderers if present'
  c.option '--include-urls', 'Gets passed to the model renderers if present'

  c.action do |args, options|
    options.default(presenter_format: "full_export", root: Pathname(args.first || Brief.pwd))

    briefcase = Brief.case = Brief::Briefcase.new(root: Pathname(args.first || options.root))

    briefcase.present(options.presenter_format, rendered: options.include_rendered,
                                                content: options.include_content,
                                                urls: options.include_urls,
                                                schema: options.include_schema,
                                                data: options.include_data,
                                                attachments: options.include_attachments,
                                                models: options.include_models)

  end
end

