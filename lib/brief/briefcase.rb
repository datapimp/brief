module Brief
  class Briefcase
    include Brief::DSL
    include Brief::Briefcase::Documentation

    attr_reader :options,
                :model_definitions

    attr_accessor :asset_finder,
                  :href_builder

    def initialize(options = {})
      @options = options.to_mash

      load_configuration
      use(:app, options[:app]) if options[:app]

      load_model_definitions

      if Brief.case(false).nil?
        Brief.case = self
      end

      @href_builder = options.fetch(:href_builder) { Brief.href_builder }
      @asset_finder = options.fetch(:asset_finder) { method(:find_asset) }

      Brief.cases[root.basename.to_s] ||= self
    end

    # Runs a command
    #
    # Commands are defined in the briefcase configuration.
    #
    # You define a command by passing a block. This block will
    # get called with the briefcase, and whatever other arguments
    def run_command(name, *args)
      if handler = Brief.commands.fetch(name.to_sym)
        block = handler[:handler]
        args.unshift(self)
        block.call(*args)
      else
        raise 'Command not found'
      end
    end

    # Returns a Hash object which presents some
    # view of the briefcase. Accepts a params hash
    # of options that will be passed to the presenter.
    #
    # The default presenter is Brief::Briefcase#as_default
    def present(style="default", params={})
      style = "default" if style.nil?

      if respond_to?("as_#{style}")
        send("as_#{style}", params)
      elsif Brief.views.key?(style.to_sym)
        block = Brief.views[style.to_sym]
        block.call(self, params)
      end
    end

    def cache_key
      "#{slug}:#{repository.cache_key}"
    end

    def slug
      options.fetch(:slug) { root.basename.to_s.parameterize }
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

    def info_hash
      {
        BRIEF_VERSION: Brief::VERSION,
        views: Brief.views.keys,
        key: folder_name.to_s.parameterize,
        name: folder_name.to_s.titlecase,
        settings: settings,
        cache_key: cache_key,
        root: root.to_s,
        paths:{
          docs_path: docs_path.to_s,
          assets_path: assets_path.to_s,
          models_path: models_path.to_s,
          data_path: data_path.to_s
        }
      }
    end

    def get_href_for(brief_uri)
      href_builder.call(brief_uri)
    end

    def get_external_url_for(asset_path)
      asset_finder.call(asset_path)
    end

    # TODO
    # The serialization of an entire briefcase at once
    # is important enough to be its own module
    def as_default(params={})
      params.symbolize_keys!

      base = info_hash

      if params[:include_data] || params[:data]
        base[:data] = data.as_json
      end

      if params[:include_schema] || params[:schema]
        base[:schema] = schema_map(!!(params[:include_schema] == "full"))
      end

      if params[:include_documentation] || params[:documentation]
        base[:documentation] = render_documentation
      end

      if params[:include_models] || params[:models]
        model_settings = {
          docs_path: docs_path
        }

        %w(urls content rendered attachments).each do |opt|
          model_settings[opt.to_sym] = !!(params[opt.to_sym] || params["include_#{opt}".to_sym])
        end

        all = all_models.compact

        base[:models] = all.map do |m|
          m.document.refresh! if params[:refresh_models]
          m.as_json(model_settings)
        end
      end

      base
    end

    def as_full_export(options={})
      options.reverse_merge!(content: true,
                             rendered: true,
                             models: true,
                             schema: true,
                             documentation: true,
                             attachments: true)
      as_default(options)
    end

    def use(module_type=:app, module_id)
      options[:app] = module_id.to_s

      run(app_config_path) if app_path.try(&:exist?)
    end

    def data
      @data ||= data!
    end

    def data!
      @data = Brief::Data::Wrapper.new(root: data_path)
    end

    def config(&block)
      Brief::Configuration.instance.tap do |cfg|
        cfg.instance_eval(&block) if block.respond_to?(:call)
      end
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

      run(config_path) if config_path.exist?
    end

    def run(code_or_file)
      code = code_or_file.is_a?(Pathname) ? code_or_file.read : code
      instance_eval(code) rescue nil
    end

    def uses_app?
      options.key?(:app) && Brief::Apps.available?(options[:app].to_s)
    end

    def app_path
      uses_app? && Brief::Apps.path_for(options[:app]).to_pathname
    end

    def app_config_path
      uses_app? && app_path.join("config.rb")
    end

    def app_models_folder
      uses_app? && app_path.join("models")
    end

    def app_namespace
      Brief::Apps.find_namespace(options[:app])
    end

    def app_models
      app_namespace.constants.map {|c| app_namespace.const_get(c) }
    end

    def model_class_for(document)
      return generic_model_class_for(document) unless uses_app?
      app_models.find {|k| k.type_alias == document.document_type } || generic_model_class_for(document)
    end

    def generic_model_class_for(document)
      Brief::Model.for_type(document.document_type) || Brief::Model.for_folder_name(document.parent_folder_name)
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
      Pathname(options.fetch(:root) { Brief.pwd }).expand_path
    end

    def find_asset(needle)
      found = assets_trail.find(needle)
      found && Pathname(found)
    end

    def assets_path
      root.join(options.fetch(:assets_path) { config.assets_path }).expand_path
    end

    def docs_path
      root.join(options.fetch(:docs_path) { config.docs_path }).expand_path
    end

    def data_path
      root.join(options.fetch(:data_path) { config.data_path }).expand_path
    end

    def assets_trail
      @assets_trail ||= Hike::Trail.new(assets_path).tap do |trail|
        trail.append_extensions '.svg', '.png', '.pdf', '.jpg', '.gif', '.mov'
        assets_path.children.select(&:directory?).each {|dir| trail.prepend_path(assets_path); trail.append_path(assets_path.join(dir)) }
      end
    end

    def docs_trail
      @docs_trail ||= Hike::Trail.new(docs_path).tap do |trail|
        trail.append_extensions '.md', '.html.md', '.markdown'
        docs_path.children.select(&:directory?).each {|dir| trail.prepend_path(docs_path); trail.append_path(docs_path.join(dir)) }
      end
    end


    def data_trail
      @docs_trail ||= Hike::Trail.new(data_path).tap do |trail|
        trail.append_extensions '.yaml', '.js', '.json', '.xls', '.xlsx', '.csv', '.txt'
        trail.append_path(data_path)
      end
    end

    def models_path
      value = options.fetch(:models_path) { config.models_path }

      if value.to_s.match(/\./)
        Pathname(Brief.pwd).join(value)
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

    def self.create_new_briefcase(options={})
      Brief::Briefcase::Initializer.new(options).run
    end
  end
end
