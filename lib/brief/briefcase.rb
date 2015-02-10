module Brief
  class Briefcase
    include Brief::DSL

    attr_reader :options,
                :model_definitions

    def initialize(options = {})
      @options = options.to_mash

      load_configuration
      load_model_definitions

      if Brief.case.nil?
        Brief.case = self
      end
    end

    def use(module_type=:app, module_id)
      if module_type == :app && apps_path.join(module_id).exist?
        config = module_type.join("config.rb")
        models = module_type.join("models")

        instance_eval(config.read) if config.exist?
        Brief.load_modules_from(models) if models.exist?
      end
    end

    def config
      Brief::Configuration.instance
    end

    def server
      @server ||= Brief::Server.new(self)
    end

    # Loads the configuration for this briefcase, either from the current working directory
    # or the configured path for the configuration file.
    def load_configuration
      config_path = options.fetch(:config_path) do
        root.join('brief.rb')
      end

      if uses_app?
        instance_eval(app_path.join("config.rb").read)
      end

      if config_path.exist?
        instance_eval(config_path.read) rescue nil
      end
    end

    def uses_app?
      options.key?(:app) && Brief.apps_path.join(options[:app]).exist?
    end

    def app_path
      uses_app? && Brief.apps_path.join(options[:app])
    end

    def load_model_definitions
      if uses_app?
        Brief.load_modules_from(app_path.join("models"))
      end

      Brief.load_modules_from(models_path) if models_path.exist?
      Brief::Model.finalize
    end

    # Returns a model name by its human readable description or its type alias
    def model(name_or_type)
      table = Brief::Model.table

      table.fetch(name_or_type) do
        table.values.find do |k|
          k.name == name_or_type
        end
      end
    end

    def root
      Pathname(options.fetch(:root) { Dir.pwd })
    end

    def docs_path
      root.join options.fetch(:docs_path) { config.docs_path }
    end

    def models_path
      value = options.fetch(:models_path) { config.models_path }

      if value.to_s.match(/\./)
        Pathname(Dir.pwd).join(value)
      elsif value.to_s.match(/\//)
        Pathname(value)
      else
        root.join(value)
      end
    end

    def repository
      @repository ||= Brief::Repository.new(self, options)
    end

    def method_missing(meth, *args, &block)
      if repository.respond_to?(meth)
        repository.send(meth, *args, &block)
      else
        super
      end
    end
  end
end
