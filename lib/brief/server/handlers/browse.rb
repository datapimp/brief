module Brief::Server::Handlers
  class Browse
    def self.handle(path_args, briefcase, options={})
      models = Array((briefcase.send(path_args) rescue nil))
      [200, {"Content-Type"=>"application/json"}, models.map(&:as_json)]
    end
  end
end
