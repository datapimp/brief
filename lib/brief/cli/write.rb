command 'write' do |c|
  c.syntax = 'brief write MODEL_TYPE [OPTIONS]'
  c.description = 'Create a new document for a given model type'

  c.action do |args, options|
    schema_map = Brief.case.schema_map(true)
    type_alias = args.first

    model_class = schema_map.fetch(type_alias) do
      raise "Unknown model type: #{ type_alias }. Available types are: #{ schema_map.keys.join(',') }"
    end

    default_example = "---\ntype:#{type_alias}\n---\n\n# Enter some content"

    content = ask_editor(model_class.to_mash.example || default_example)

    file = ask("Enter a filename")

    if file.to_s.length == 0
      rand_token = rand(36**36).to_s(36).slice(0,6)
      file = "new-#{ type_alias }-#{ rand_token }.md"
    end

    folder = Brief.case.docs_path.join(type_alias.pluralize)
    folder = folder.exist? ? folder : Brief.case.docs_path

    folder.join(file).open("w+") do |fh|
      fh.write(content)
    end

    puts "== Successfully created #{ folder.join(file) }"
  end
end
