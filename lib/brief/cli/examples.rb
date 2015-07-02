command "view example" do |c|
  c.syntax = "brief view example MODEL"
  c.description = "View an example document"
  c.option '--format TYPE', String, 'Which format to present the information. json, or table'

  c.action do |args, options|
    options.default(format: 'editor')
    model = args.first

    briefcase = Brief.case = Brief::Briefcase.new(root: Pathname(options.root || Brief.pwd))
    schema_map = briefcase.schema_map(false)

    payload = schema_map

    if args.length > 0
      payload = schema_map.fetch(args.first) do
        raise "Invalid model."
      end
    end

    puts "Viewing Documentation for #{ payload }"
  end
end

command "view documentation" do |c|
  c.syntax = "brief view documentation for MODEL"
  c.description = "View the documentation for a model"
  c.option '--format TYPE', String, 'Which format to present the information. json, or table'

  c.action do |args, options|
    options.default(format: 'editor')
    model = args.first

    briefcase = Brief.case = Brief::Briefcase.new(root: Pathname(options.root || Brief.pwd))
    schema_map = briefcase.schema_map(false)

    payload = schema_map

    if args.length > 0
      payload = schema_map.fetch(args.first) do
        raise "Invalid model."
      end
    end

    puts "Viewing Documentation for #{ payload }"
  end
end
