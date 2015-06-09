command 'write' do |c|
  c.syntax = 'brief write MODEL_TYPE [OPTIONS]'
  c.description = 'Create a new document for a given model type'

  # TODO
  # We could potential query the available model classes we are aware of
  # and determine which CLI arguments those model classes may ask for.
  c.action do |args, options|
    schema_map = Brief.case(true).schema_map(true)
    type_alias = args.first

    model_class = schema_map.fetch(type_alias) do
      raise "Unknown model type: #{ type_alias }. Available types are: #{ schema_map.keys.join(',') }"
    end

    # TODO
    #
    # We need to determine the initial content that gets put into the editor.
    #
    # Our options are:
    #
    # - use an example from the model, if one exists
    # - deduce the content to use based on some combination of one or more of the items below:
    #   - specifics of the model
    #   - the state of the documents that exist for that model already
    #   - the arguments from the CLI
    default_example = "---\ntype:#{type_alias}\n---\n\n# Enter some content"

    content = ask_editor(model_class.to_mash.example || default_example)

    file = ask("Enter a filename")

    if file.to_s.length == 0
      rand_token = rand(36**36).to_s(36).slice(0,6)
      file = "new-#{ type_alias }-#{ rand_token }.md"
    end

    folder = Brief.case(true).docs_path.join(type_alias.pluralize)
    folder = folder.exist? ? folder : Brief.case.docs_path

    folder.join(file).open("w+") do |fh|
      fh.write(content)
    end

    puts "== Successfully created #{ folder.join(file) }"
  end
end
