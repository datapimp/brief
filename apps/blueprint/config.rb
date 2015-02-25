view(:summary) do |*args|
  params = args.extract_options!
  briefcase = args.first

  briefcase.present(:default, params).tap do |hash|
    if summary = briefcase.pages.find {|p| p.title == "Summary" }
      hash.merge!(summary: summary.to_model.as_json(:rendered=>true, :content=>true))
    end
  end
end
