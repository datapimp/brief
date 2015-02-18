module Brief::Server::Handlers
  class Info
    def self.handle(path, briefcase, options={})
      request = options.fetch(:request)
      action = options.fetch(:action)

      schema = {}
      models = {}

      Brief::Model.classes.map do |k|
        schema[k.type_alias] = k.to_schema

        a = k.type_alias.to_s.pluralize
        models[a] = briefcase.send(a).map {|m| m.as_json(docs_path: briefcase.docs_path) }
      end

      [200, {}, {name: briefcase.folder_name.to_s, schema: schema, models: models}]
    end
  end
end
