command 'schema' do |c|
  c.syntax = "brief schema"
  c.description = "view information about the schema"

  c.option '--existing-models', 'Include all models, not just those that have documents'

  c.action do |args, options|
    schema_map = Brief.case(true).schema_map(!!!options.existing_models)

    output = if args.empty?
      schema_map.to_json
    else
      detail = schema_map.fetch(args.first.downcase, nil)
      detail.to_json if detail
    end

    output
  end
end
