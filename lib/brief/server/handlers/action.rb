module Brief::Server::Handlers
  class Action
    def self.handle(path_args, briefcase, options={})
      parts = path_args.split("/")
      action = parts.shift
      path = parts.join("/")

      document = briefcase.document_at(path)

      headers = {
        "Content-Type" => "application/json"
      }

      if !document
        return [404,headers,{error:"Could not find a document at this path"}]
      end

      model = document.to_model

      if !model.class.defined_actions.include?(action.to_sym)
        [400, headers, {error:"Invalid action: #{ action }"}]
      else
        model.send(action)
        [200, headers, model.as_json]
      end
    end
  end
end
