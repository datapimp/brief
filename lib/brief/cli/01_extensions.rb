class Commander::Command
  def action(*a, &block)
    Brief.default_cli_options(self)

    when_called do |args, options|
      options.default(root: Brief.pwd, config_filename: 'brief.rb', format: :printed, prefix_output: "")

      root = Pathname(options.root)

      if root.join(options.config_filename).exist?
        Brief.case = lambda do
          Brief::Briefcase.new(root: Pathname(options.root))
        end
      end

      result = block.call(args, options)

      case
      when options.output && options.format.to_sym == :json
        Pathname(options.output).open("w+") do |fh|
          fh.write("#{options.prefix_output}#{result.to_json}")
        end
      when options.format.to_sym == :json
        puts "#{options.prefix_output}#{result.to_json}"
      when options.format.to_sym == :printed
        puts result
      end

    end
  end
end

module Brief
  def self.default_cli_options(c)
    c.option '--root DIRECTORY', String, 'The root for the briefcase'
    c.option '--config FILE', String, 'Path to the config file for this briefcase'
    c.option '--config-filename', String, 'The default filename for a briefcase config: brief.rb'
    c.option '--output FILE', String, 'Save the output in the specified path'
    c.option '--format FORMAT', String, 'How to format the CLI output: defaults to printed, accepts printed,json'
    c.option '--prefix-output CONTENT', String, 'Prefix the generated output with the following content'
  end
end
