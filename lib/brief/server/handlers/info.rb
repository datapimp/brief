module Brief::Server::Handlers
  class Info
    def self.handle(path, briefcase, options={})
      request = options.fetch(:request)
      action = options.fetch(:action)

      [200, {}, briefcase.as_default]
    end
  end
end
