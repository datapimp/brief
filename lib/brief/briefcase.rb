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

      Brief.cases[root] ||= self
    end

    def present(style="default", params={})
      if respond_to?("as_#{style}")
        send("as_#{style}", params)
      elsif Brief.views.key?(style.to_sym)
        block = Brief.views[style.to_sym]
        block.call(self, params)
      end
    end

    def settings
      @settings ||= settings!
    end

    def settings!
      if root.join("settings.yml").exist?
        y = YAML.load(root.join("settings.yml").read) rescue nil
        (y || {}).to_mash
      end
    end

    def as_default(params={})
      params.symbolize_keys!

      model_settings = {
        docs_path: docs_path
      }

      model_settings[:rendered] = !!(params.key?(:rendered))
      model_settings[:content] = !!(params.key?(:content))

      all = all_models.compact

      schema = all.map(&:class).uniq.compact
                 .map(&:to_schema)
                 .reduce({}) {|m, k| m[k[:type_alias]] = k; m }

      models = all.map {|m| m.as_json(model_settings) }

      {
        views: Brief.views.keys,
        key: briefcase.folder_name.to_s.parameterize,
        name: briefcase.folder_name.to_s.titlecase,
        schema: schema,
        models: models,
        settings: settings
      }
    end

    def as_full_export
      as_default(content: true, rendered: true)
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

    def server(options={})
      @server ||= Brief::Server.new(self, options)
    end

    def folder_name
      root.basename
    end

    # Loads the configuration for this briefcase, either from the current working directory
    # or the configured path for the configuration file.
    def load_configuration
      config_path = options.fetch(:config_path) do
        root.join('brief.rb')
      end

      if config_path.is_a?(String)
        config_path = root.join(config_path)
      end

      if uses_app?
        instance_eval(app_path.join("config.rb").read)
      end

      if config_path.exist?
        instance_eval(config_path.read) rescue nil
      end
    end

    def uses_app?
      options.key?(:app) && Brief::Apps.available?(options[:app].to_s)
    end

    def app_path
      uses_app? && Brief::Apps.path_for(options[:app]).to_pathname
    end

    def model_class_for(document_type)
      return generic_model_class_for(document_type) unless uses_app?

      namespace = Brief::Apps.find_namespace(options[:app])
      classes = namespace.constants.map {|c| namespace.const_get(c) }
      classes.find {|k| k.type_alias == document_type }
    end

    def generic_model_class_for(document_type)
      Brief::Model.for_type(document_type) || Brief::Model.for_folder_name(parent_folder_name)
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
      if Brief.views.key?(meth.to_sym)
        block = Brief.views[meth.to_sym]
        block.call(self, args.extract_options!)
      elsif repository.respond_to?(meth)
        repository.send(meth, *args, &block)
      else
        super
      end
    end
  end
end
