class Brief::Server::Gateway
  attr_reader :root

  def initialize(options={})
    @root = options.fetch(:root)
    @briefcases = {}
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
    name    = request.path.match(/\/\w+\/(\w+)/)[1] rescue nil

    if name && @briefcases[name]
      @briefcases[name].server.call(env)
    else
      [404, {}, ["Not found: #{ name } -- #{ request.path }"]]
    end
  end
end
