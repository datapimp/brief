class Brief::Server
  attr_reader :options, :briefcase

  def initialize(briefcase, options={})
    @briefcase = briefcase
    @options = options
  end

  def call(env)
    request = Brief::Server::Route.new(env, briefcase, options)
    status, headers, body = request.respond()

    body = body.to_json if body.is_a?(Hash)
    body = body.to_json if body.is_a?(Array)
    body = body.as_json.to_json if body.is_a?(Brief::Model)

    body = "" if body.nil?

    headers["Content-Length"]                 = Rack::Utils.bytesize(body).to_s
    headers["Access-Control-Allow-Origin"]    = "*"
    headers["Access-Control-Allow-Methods"]   = "GET, POST, PUT"
    headers["X-BRIEF-HANDLER"] = request.send(:handler).try(:to_s)

    [status, headers, [body]]
  end
end

require 'brief/server/route'
