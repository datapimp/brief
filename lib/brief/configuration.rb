require 'singleton'

module Brief
  class Configuration
    include Singleton

    def self.method_missing(meth, *args, &block)
      if instance.respond_to?(meth)
        instance.send(meth, *args, &block)
      else
        super
      end
    end

    def current
      @current ||= {
        docs_path: 'docs',
        models_path: 'models',
        templates_path: 'templates',
        data_path: 'data',
        assets_path: 'assets'
      }.to_mash
    end

    def set(attribute, value = nil)
      current[attribute] = value
      self
    end

    def method_missing(meth, *args, &block)
      if current.respond_to?(meth) && current.key?(meth)
        current.send(meth, *args, &block)
      else
        # swallow invalid method calls in production
        super if ENV['BRIEF_DEBUG_MODE']
        nil
      end
    end
  end
end
