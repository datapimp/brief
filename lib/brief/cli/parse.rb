command 'parse' do |c|
  c.syntax = 'brief parse PATH [OPTIONS]'
  c.description = 'parse the briefcase path'

  c.option '--output-type TYPE', String, 'Valid options: hash, array; Output as a hash keyed by path, or an array. Defaults to array.'
  c.option '--config-path FILE', String, 'Path to the config file for the briefcase'

  c.action do |args, options|
    options.default(root: Pathname(Brief.pwd), output_type: "array")

    o = {
      root: options.root
    }

    o[:config_path] = options.config_path if options.config_path

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
