module Brief::Server::Handlers
  class Schema
    def self.handle(path_args, briefcase, options)
      request = options.fetch(:request)

      headers = {"Content-Type"=>"application/json"}

      if request.path == "/schema"
        [200, headers, Brief::Model.classes.map(&:to_schema)]
      elsif request.path.match(/^\/schema\/(.+)$/)
        requested = request.path.split("/").last

        if model = Brief::Model.lookup(requested)
          [200, headers, model.to_schema]
        else
          [404, headers, {error: "Can not find model class matching #{ requested }"}]
        end
      end
    end
  end
end
