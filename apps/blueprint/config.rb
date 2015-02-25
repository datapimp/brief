view(:summary) do |briefcase, params|
  summary = where(title:"Summary",type:"page").first.to_model.as_json(:rendered=>true, :content=>true)
  briefcase.present(:default, params).merge(summary: summary)
end
