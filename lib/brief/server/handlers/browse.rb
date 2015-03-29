module Brief::Server::Handlers
  class Browse
    def self.available_handlers
      Brief::Model.classes.map(&:type_alias).map(&:pluralize)
    end

    def self.handle(path_args, briefcase, options={})
      model_type = Array(path_args).first

      if available_handlers.include?(model_type)
        models = briefcase.send(model_type.to_s)

        presented_models = models.map do |model|
          model.as_json(options.symbolize_keys)
        end

        [200, {"Content-Type"=>"application/json"}, presented_models]
      else
        [403, {"Content-Type"=>"application/json"}, {error: "Invalid model type"}]
      end
    end
  end
end
