module Brief::Server::Handlers
  class Info
    def self.handle(path, briefcase, options={})
      request = options.fetch(:request)
      params  = request.params.symbolize_keys
      style   = params.fetch(:presenter, "default")

      [200, {}, briefcase.present(style, params)]
    end
  end
end
