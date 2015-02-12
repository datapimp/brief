module Brief::Server::Handlers
  class Schema
    def self.handle(path_args, request, briefcase)
      [400, {}, {}]
    end
  end
end
