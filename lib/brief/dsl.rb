module Brief
  module DSL
    extend ActiveSupport::Concern

    def config(options={}, &block)
      Brief::Configuration.instance.load_options(options) unless options.nil? || options.empty?
      Brief::Configuration.instance.instance_eval(&block) if block_given?
    end

    def define(*args, &block)
      definition = Brief::Model::Definition.new(args.first, args.extract_options!)
      definition.instance_eval(&block) if block_given?
      definition.validate!
    end
  end
end
