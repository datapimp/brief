module Brief::Server::Handlers
  class Aggregator
    def self.handle(path, briefcase, options={})
      [200, {"Content-Type"=>"application/json"}, briefcase.send(path)]
    end
  end
end

