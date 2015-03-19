command 'parse' do |c|
  c.syntax = 'brief parse PATH [OPTIONS]'
  c.description = 'parse the briefcase path'

  c.option '--root PATH', String, 'The briefcase root'
  c.option '--output PATH', String, 'Save the output to the specified path'
  c.option '--app APP', String, 'Use the specified app to get our models etc'
  c.option '--config PATH', String, 'Use the specified config file'
  c.option '--type TYPE', String, 'Valid options: hash, array; Output as a hash keyed by path, or an array. Defaults to array.'

  c.action do |args, options|
    options.default(root: Pathname(Dir.pwd), type: "array")

    o = {
      root: options.root
    }

    o[:app] = options.app if options.app
    o[:config_path] = options.config if options.config

    briefcase = Brief::Briefcase.new(o)

    parsed = if args.empty?
      briefcase.all_models.map do |model|
        model.as_json(content:true, rendered: true)
      end
    else
      args.map do |a|
        Dir[briefcase.root.join(a)].map do |f|
          doc = Brief::Document.new(f).in_briefcase(briefcase)
          doc.to_model.as_json(content: true, rendered: true)
        end
      end.flatten
    end

    if options.type == "hash"
      parsed = parsed.inject({}) do |memo, obj|
        path = obj[:path]
        memo[path] = obj
        memo
      end
    end

    if options.output
      Pathname(options.output).open("w+") {|fh| fh.write(parsed.to_json) }
    else
      puts parsed.to_json
    end
  end
end
