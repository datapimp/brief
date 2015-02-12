module Brief::Server::Handlers
  class Browse
    def self.handle(path_args, request, briefcase)
      models = Array(briefcase.send(path_args))
      [200, {"Content-Type"=>"application/json"}, [models.map(&:as_json)]]
    end
  end
end
