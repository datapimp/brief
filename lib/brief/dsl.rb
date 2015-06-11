module Brief
  module DSL
    extend ActiveSupport::Concern

    def config(options = {}, &block)
      Brief::Configuration.instance.instance_eval(&block) if block_given?
    end

    # Define a view of the briefcase.  Pass a block
    # which returns a hash that displays the desired
    # content
    def view(name, &block)
      Brief.views[name.to_sym] = block
    end

    # Register a new command for this briefcase.
    #
    # Pass the name of the command, options, and a block.
    #
    # The block will get called with the briefcase, and any arguments
    #
    # currently doesn't accept any options
    def command(name, options={}, &block)
      Brief.commands[name.to_sym] = {
        options: options,
        handler: block
      }
    end

    # Extends an existing class
    def extend(*args, &block)
      options     = args.dup.extract_options!
      name        = args.first
      type_alias  = options.fetch(:type_alias) { name.downcase.parameterize.gsub(/-/, '_') }

      namespace = Brief.configuration.model_namespace || Brief::Model

      klass = namespace.const_get(type_alias.camelize) rescue nil

      if !klass
        return define(*args, &block)
      end

      klass.definition.instance_eval(&block) if block_given?
      klass.definition.validate!
    end

    # defines a new model class
    def define(*args, &block)
      options     = args.dup.extract_options!
      name        = args.first
      type_alias  = options.fetch(:type_alias) { name.downcase.parameterize.gsub(/-/, '_') }

      namespace = Brief.configuration.model_namespace || Brief::Model

      klass = namespace.const_get(type_alias.camelize) rescue nil

      klass = namespace.const_set(type_alias.camelize, Class.new).tap do |k|
        k.send(:include, Brief::Model)
        k.definition ||= Brief::Model::Definition.new(args.first, args.extract_options!)
        k.name ||= name
        k.type_alias ||= type_alias
        Brief::Model.classes << k
      end if klass.nil?

      klass.definition.instance_eval(&block) if block_given?
      klass.definition.validate!
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
