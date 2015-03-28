command 'schema' do |c|
  c.syntax = "brief schema"
  c.description = "view information about the schema"

  Brief.default_cli_options(c)

  c.option '--output FILE', String, 'Output the contents to the specified file'
  c.option '--all-models', 'Include all models, not just those that have documents'
  c.option '--list-types', 'Only list the types'

  Brief.cli_action(c) do |args, options|
    schema_map = Brief.case.schema_map(options.all_models)

    output = if args.empty?
      schema_map.to_json
    else
      detail = schema_map.fetch(args.first.downcase, nil)
      detail.to_json if detail
    end

    if options.output
      Pathname(options.output).open "w+" do |fh|
        fh.write(output.chomp)
      end
    else
      puts output
    end
  end
end
