class Brief::Server::Route
  attr_reader :env, :request, :briefcase, :prefix
  attr_accessor :code, :headers, :body

  def initialize(env, briefcase, options={})
    @env = env
    @request = Rack::Request.new(env)
    @briefcase = briefcase
    @prefix = options.fetch(:prefix, "/briefcase")
    @code = 200
    @headers = {}
    @body = {}
  end

  def respond
    status, headers, body = response_data
    [status, headers, body]
  end

  private
    def response_data
    end

    def actual_path
      request.path[/^#{ prefix }\/(\w+)\/(.+)$/, 2]
    end

    def response_data
      [code, headers, body]
    end
end
