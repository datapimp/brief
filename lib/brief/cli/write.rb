command "write" do |c|
  c.syntax = "brief write MODEL_TYPE [OPTIONS]"
  c.description = "Create a new document for a given model type"

  c.action do |args, options|
    string_args = args.select {|a| a.is_a?(String) }
    model_class = Brief::Model.lookup_class_from_args(string_args)

    base_content = ""

    if model_class && model_class.example_body.to_s.length > 0
      base_content = model_class.example_body
    else
      #document_contents = model_class.inspect + model_class.example_body.to_s
    end

    document_contents = ask_editor(base_content)
    file = ask("enter a name for this file:", String)

    puts file
    puts document_contents
  end
end
