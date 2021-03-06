class Brief::Server::Gateway
  attr_reader :root, :briefcases

  def self.start(options={})
    app = new(root: Pathname(options[:root]))
    port = options.fetch(:port, 9094)
    host = options.fetch(:host, '0.0.0.0')
    Rack::Handler::Thin.run(app, Port: port, Host: host)
  end

  attr_reader :briefcases

  def initialize(options={})
    @root = options.fetch(:root)
    @briefcases = {}.to_mash
    @briefcase_options = options.fetch(:briefcase_options, {})
    load_briefcases
  end

  def briefcase_options
    (@briefcase_options || {})
  end

  def load_briefcases
    config_path = briefcase_options.fetch(:config_path, "brief.rb")

    root.children.select(&:directory?).each do |dir|
      if dir.join(config_path).exist?
        slug = dir.basename.to_s.parameterize
        @briefcases[slug] ||= Brief::Briefcase.new(briefcase_options.merge(root: dir))
      end
    end
  end

  def call(env)
    request = Rack::Request.new(env)
    params  = request.params.symbolize_keys

    if request.path.match(/\/all$/)
      presenter = params.fetch(:presenter, 'default')
      return [200, {}, [
        @briefcases.values.map do |bc|
          bc.present(presenter, params)
        end.to_json
      ]]
    end

    name    = request.path.match(/\/\w+\/(\w+)/)[1] rescue nil

    if name && @briefcases[name]
      @briefcases[name].server.call(env)
    else
      [404, {}, ["Not found: #{ name } -- #{ request.path }"]]
    end
  end
end
