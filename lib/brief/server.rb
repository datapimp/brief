
class Brief::Server
  attr_reader :options, :briefcase

  def initialize(briefcase, options={})
    @briefcase = briefcase
    @options = options
  end

  def call(env)
    request = Brief::Server::Route.new(env, briefcase, options)
    status, headers, body = request.respond()

    headers["Content-Length"]                 = Rack::Utils.bytesize(body)
    headers["Access-Control-Allow-Origin"]    = "*"
    headers["Access-Control-Allow-Methods"]   = "GET, POST, PUT"

    [status, headers, [body]]
  end
end

require 'brief/server/route'
