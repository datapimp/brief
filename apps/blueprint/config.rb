view(:summary) do |briefcase, params|
  briefcase.present(:default, params).tap do |hash|
    if summary = where(title:"Summary",type:"page").first
      hash.merge!(summary: summary.to_model.as_json(:rendered=>true, :content=>true))
    end
  end
end
