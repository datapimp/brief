command 'schema' do |c|
  c.syntax = "brief schema [MODEL_CLASS]"
  c.description = "view information about the schema"

  c.option '--existing-models', 'Include all models, not just those that have documents'
  c.option '--format TYPE', String, 'Which format to present the information. json, or table'

  c.action do |args, options|
    options.default(format: 'table')
    briefcase = Brief.case = Brief::Briefcase.new(root: Pathname(args.first || options.root))
    schema_map = briefcase.schema_map(!!!options.existing_models)

    payload = schema_map

    if args.length > 0
      payload = schema_map.fetch(args.first) do
        raise "Invalid model."
      end
    end

    if options.format == "json"
      output = payload.to_json

      if options.output
        Pathname(options.output).open("w+") {|fh| fh.write(output) }
      else
        puts output
      end
    end

    if options.format == "table"
      rows = []
      schema_map.each do |type, definition|
        defined_in = definition.defined_in.to_s.split("/").reverse.slice(0,3).reverse.join("/")
        rows.push [type, definition.name, defined_in]
      end

      require 'terminal-table'
      table = Terminal::Table.new(:rows => rows, :headings => %w(Type Model Defined-In))
      puts table
    end

  end
end
