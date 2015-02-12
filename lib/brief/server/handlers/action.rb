module Brief::Server::Handlers
  class Action
    def self.handle(path_args, request, briefcase)
      [400, {}, {}]
    end
  end
end
