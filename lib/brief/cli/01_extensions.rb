class Commander::Command
  def action(*args, &block)
    Brief.default_cli_options(self)

    when_called do |args, options|
      options.default(root: Brief.pwd)
      Brief.case = Brief::Briefcase.new(root: Pathname(options.root))

      block.call(args, options)
    end
  end
end

module Brief
  def self.cli_action(c, &block)
    c.action do |args, options|
      options.default(root: Brief.pwd)

      Brief.case = Brief::Briefcase.new(root: Pathname(options.root))

      block.call(args, options)
    end
  end

  def self.default_cli_options(c)
    c.option '--root DIRECTORY', String, 'The root for the briefcase'
    c.option '--config FILE', String, 'Path to the config file for this briefcase'
  end
end
