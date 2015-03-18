command 'export' do |c|
  c.syntax= 'brief export [OPTIONS]'
  c.description = 'Export a parsed version of the document collection'

  c.option '--include-content', nil, 'whether to include the unparsed content'
  c.option '--include-rendered', nil, 'whether to include the rendered content'
  c.option '--config-path PATH', String, 'Path to the config file'

  c.action do |args, options|
    options.default :config_path => Pathname(Dir.pwd).join('brief.rb')


    briefcase = Brief::Briefcase.new(config_path: Pathname(options.config_path))

    dump = briefcase.as_full_export()

    output = args.first || "#{ briefcase.cache_key }.json"

    Pathname(Dir.pwd).join(output).open("w+") {|fh| fh.write(dump.to_json) }
  end
end
