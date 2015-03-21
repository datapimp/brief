command 'export' do |c|
  c.syntax = 'brief export PATH [OPTIONS]'
  c.description = 'export the briefcase found in PATH'

  c.option '--output PATH', String, 'Save the output to the specified path'
  c.option '--app APP', String, 'Use the specified app to get our models etc'
  c.option '--config PATH', String, 'Use the specified config file'

  c.action do |args, options|
    root = Pathname(args.first || Brief.pwd)

    o = {
      root: root
    }

    o[:app] = options.app if options.app
    o[:config_path] = options.config if options.config

    briefcase = Brief::Briefcase.new(o)

    export = briefcase.as_full_export.to_json

    if options.output
      output = Pathname(options.output)
      output = output.join(briefcase.slug + ".json") if output.directory?

      output.open("w+") {|fh| fh.write(export) }
    else
      puts export
    end
  end
end

