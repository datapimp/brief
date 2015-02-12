module TestHelpers
  def app
    Brief.testcase.server
  end

  def json
    @json ||= JSON.parse(last_response.body)
  end

  def env_for(*args)
    Rack::MockRequest.send(:env_for, *args)
  end

  def route_for(*args)
    env = env_for(*args)
    Brief::Server::Route.new(env, Brief.testcase)
  end

  def handler_for(*args)
    route_for(*args).send(:handler)
  end
end
