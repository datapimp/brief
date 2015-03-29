view(:summary) do |*args|
  params = args.extract_options!
  briefcase = args.first

  briefcase.present(:default, params).tap do |hash|
    if summary = briefcase.pages.find {|p| p.title == "Summary" }
      hash.merge!(summary: summary.to_model.as_json(:rendered=>true, :content=>true))
    end
  end
end

view(:table_of_contents) do |*args|
  briefcase = args.first

  doc = Brief::Document.new(briefcase.docs_path.join("index.md"), document_type: "outline")
  doc && doc.to_model
end
