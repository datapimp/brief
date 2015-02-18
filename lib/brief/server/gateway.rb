class Brief::Server::Gateway
  attr_reader :root

  def initialize(options={})
    @root = options.fetch(:root)
    @briefcases = {}

    load_briefcases
  end

  def load_briefcases
    root.children.select(&:directory?).each do |dir|
      if dir.join("brief.rb").exist?
        slug = dir.basename.to_s.parameterize
        @briefcases[slug] ||= Brief::Briefcase.new(root: dir)
      end
    end
  end

  def call(env)
    request = Rack::Request.new(env)
    name    = request.path.match(/\/\w+\/(\w+)/)[1] rescue nil

    if name && @briefcases[name]
      @briefcases[name].server.call(env)
    else
      [404, {}, ["Not found"]]
    end
  end
end
