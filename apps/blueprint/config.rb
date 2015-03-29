view(:summary) do |*args|
  params = args.extract_options!
  briefcase = args.first

  briefcase.present(:default, params).tap do |hash|
    if summary = briefcase.pages.find {|p| p.title == "Summary" }
      hash[:summary] = summary.to_model.as_json(params)
    end

    if briefcase.has_table_of_contents?
      hash[:table_of_contents] = table_of_contents.as_json(params)
    end
  end
end

class Brief::Briefcase
  def has_table_of_contents?
    docs_path.join('index.md').exist?
  end

  def table_of_contents
    doc = Brief::Document.new(briefcase.docs_path.join("index.md"), document_type: "outline")
    doc && doc.to_model
  end
end
