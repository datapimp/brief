command 'write' do |c|
  c.syntax = 'brief write MODEL_TYPE [OPTIONS]'
  c.description = 'Create a new document for a given model type'

  # TODO
  # We could potential query the available model classes we are aware of
  # and determine which CLI arguments those model classes may ask for.
  c.action do |args, options|
    options.default(root: Pathname(Brief.pwd))
    briefcase = Brief.case = Brief::Briefcase.new(root: options.root)
    schema_map = briefcase.schema_map()

    type_alias = args.first

    model_class = schema_map.fetch(type_alias) do
      raise "Unknown model type: #{ type_alias }. Available types are: #{ schema_map.keys.join(',') }"
    end

    content = ask_editor model_class.writing_prompt()

    file = ask("Enter a filename")

    if file.to_s.length == 0
      rand_token = rand(36**36).to_s(36).slice(0,3)
      file = "new-#{ type_alias }-#{ rand_token }.md"
    end

    folder = briefcase.docs_path.join(type_alias.pluralize)
    folder = folder.exist? ? folder : briefcase.docs_path

    folder.join(file).open("w+") do |fh|
      fh.write(content)
    end

    puts "== Successfully created #{ folder.join(file) }"
  end
end
