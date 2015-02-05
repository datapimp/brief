module Brief
  module DSL
    extend ActiveSupport::Concern

    def config(options = {}, &block)
      Brief::Configuration.instance.instance_eval(&block) if block_given?
    end

    def define(*args, &block)
      definition = Brief::Model::Definition.new(args.first, args.extract_options!)
      definition.instance_eval(&block) if block_given?
      definition.validate!
    end

    # defines a method on the model instance named after the identifier
    # and then creates a CLI command matching that, so for example:
    #
    # given a model called 'Post' and an action named 'publish' the
    # brief CLI executable will respond to:
    #
    #   brief publish posts PATH_GLOB
    #
    # this will find all of the Post models from the documents matching PATH_GLOB
    # and call the publish method on them
    def action(identifier, _options = {}, &block)
      Object.class.class_eval do
        command "#{identifier}" do |c|
          c.syntax = "brief #{identifier}"
          c.description = "run the #{identifier} command"

          c.action do |args, opts|
            briefcase = Brief.case

            path_args = args.select { |arg| arg.is_a?(String) && arg.match(/\.md$/) }

            path_args.select! do |arg|
              path = briefcase.repository.root.join(arg)
              path.exist?
            end

            path_args.map! { |p| briefcase.repository.root.join(p) }

            models = path_args.map { |path| Brief::Document.new(path) }.map(&:to_model)

            block.call(Brief.case, models, opts)
          end
        end rescue nil
      end
    end
  end
end
