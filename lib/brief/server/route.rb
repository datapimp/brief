class Brief::Server::Route
  attr_reader :env, :request, :briefcase, :prefix
  attr_accessor :code, :headers, :body

  def initialize(env, briefcase, options={})
    @env = env
    @request = Rack::Request.new(env)
    @briefcase = briefcase
    @prefix = options.fetch(:prefix) {"/briefcases/#{ briefcase.folder_name.to_s.parameterize }"}
    @code = 400
    @headers = {}
    @body = {}
  end

  def respond
    status, headers, body = response_data
    [status, headers, body]
  end

  private

    def response_data
      resp = handler.handle(path_args, briefcase, request: request, action: path_action)

      self.code = resp[0]
      self.headers.merge(resp[1])
      self.body = resp[2]

      [code, headers, body]
    end

    def handlers
      Brief::Server::Handlers
    end

    def handler
      case
      when request.path.match(/^\/schema/)
        handlers.const_get(:Schema)
      when path_action == "browse"
        handlers.const_get(:Browse)
      when %w(create update delete remove).include?(path_action)
        handlers.const_get(:Modify)
      when path_action == "actions"
        handlers.const_get(:Action)
      when path_action == "view"
        handlers.const_get(:Show)
      else
        handlers.const_get(:Info)
      end
    end

    def format
      "application/json"
    end

    def without_prefix
      request.path.gsub(prefix, '')
    end

    def path_action
      without_prefix[/^\/(\w+)\/(.+)$/, 1].to_s.downcase
    end

    def path_args
      without_prefix[/^\/(\w+)\/(.+)$/, 2]
    end
end

require "brief/server/handlers/action"
require "brief/server/handlers/info"
require "brief/server/handlers/browse"
require "brief/server/handlers/modify"
require "brief/server/handlers/schema"
require "brief/server/handlers/show"
