command 'write' do |c|
  c.syntax = 'brief write MODEL_TYPE [OPTIONS]'
  c.description = 'Create a new document for a given model type'

  # TODO
  # We could potential query the available model classes we are aware of
  # and determine which CLI arguments those model classes may ask for.
  c.action do |args, options|
    options.default(root: Pathname(Brief.pwd))
    briefcase = Brief.case = Brief::Briefcase.new(root: options.root)
    type_alias = args.first

    model_class = briefcase.model_classes.find {|c| c.type_alias == type_alias }

    if !model_class.nil?
      content = ask_editor model_class.writing_prompt()
    else
      model_class = briefcase.schema_map.fetch(type_alias, nil)
      content = ask_editor(model_class.example)
    end

    raise "Inavlid model class. Run the schema command to see what is available." if model_class.nil?


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
