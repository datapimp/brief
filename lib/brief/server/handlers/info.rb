module Brief::Server::Handlers
  class Info
    def self.handle(*args)
      [200, {}, {}]
    end
  end
end
