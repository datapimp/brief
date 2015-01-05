module Brief
  class Briefcase
    include Brief::DSL

    attr_reader :options,
                :model_definitions

    def initialize(options={})
      @options = options.to_mash

      load_configuration
      load_model_definitions
    end

    def config
      Brief::Configuration.instance
    end

    # Loads the configuration for this briefcase, either from the current working directory
    # or the configured path for the configuration file.
    def load_configuration
      config_path = options.fetch(:config_path) do
        root.join("brief.rb")
      end

      if config_path.exist?
        instance_eval(config_path.read)
      end
    end

    def load_model_definitions
      if models_path.exist?
        Dir[models_path.join("**/*.rb")].each {|f| require(f) }
      end

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
      root.join options.fetch(:models_path) { config.models_path }
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
