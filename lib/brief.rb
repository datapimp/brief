require 'pathname'
require 'set'
require 'hashie'
require 'virtus'
require 'inflecto'
require 'active_support'
require 'active_support/core_ext'
require 'nokogiri'
require 'yaml'
require 'erb'
require 'hike'
require 'pry'
require 'logger'

module Brief
  # When packaging this up through the traveling ruby system
  # Dir.pwd is not accurate because of the wrapper. We shim it
  # by setting a special ENV variable in that file
  def self.pwd
    ENV.fetch('BRIEF_PWD') { Dir.pwd }
  end

  def self.home
    Pathname(ENV['HOME']).join(".brief")
  end

  def self.initialize_home!
    FileUtils.mkdir_p(home)
  end

  def self.cases
    @cases ||= {}
  end

  def self.case=(value)
    @briefcase = value
  end

  def self.case(fire=false)
    if @briefcase.is_a?(Brief::Briefcase)
      @briefcase
    elsif fire && @briefcase.respond_to?(:call)
      @briefcase = @briefcase.call()
    else
      @briefcase
    end
  end

  def self.views
    @views ||= {}
  end

  def self.commands
    @commands ||= {}
  end

  def self.environment_info
    {
      VERSION: Brief::VERSION,
      lib_root: Brief.lib_root.to_s,
      apps: {
        search_paths: Brief::Apps.search_paths.map(&:to_s),
        available: Brief::Apps.available_apps
      }
    }
  end

  def self.configuration
    Brief::Configuration.instance
  end

  def self.lib_root
    Pathname(File.dirname(__FILE__))
  end

  def self.apps_path
    lib_root.join("..","apps")
  end

  def self.load_commands
    Dir[lib_root.join('brief', 'cli', '**/*.rb')].each { |f| require(f) }
    create_command_dispatchers
  end

  def self.create_command_dispatchers
    # Each Brief::Model can define certain "actions" which can be called on the documents.
    #
    # The Brief CLI interface lets users dispatch these actions to the documents specified by the PATH args.
    Brief::Model.classes.each do |klass|
      Array(klass.defined_actions).uniq.each do |action|
        Brief::Util.create_method_dispatcher_command_for(action, klass)
      end
    end
  end

  def self.default_model_class
    if defined?(Brief::DefaultModel)
      Brief::DefaultModel
    else
      Brief.const_set(:DefaultModel, Class.new { include Brief::Model; def self.type_alias; "default"; end })
    end
  end

  def self.load_modules_from(folder)
    Dir[folder.join('**/*.rb')].each do |f|
      #puts "Loading model from #{ f }"
      require(f)
    end
  end

  # Adapters for Rails, Middleman, or Jekyll apps
  def self.activate_adapter(identifier)
    require "brief/adapters/#{ identifier }"
    (Brief::Adapters.const_get(identifier.camelize) rescue nil).tap do |adapter|
      raise "Invalid adapter: #{ identifier }" unless adapter
    end
  end

  # This can be overridden so that you can generate uri values
  # in the renderings that fit within the medium (e.g. website, electron app)
  def self.href_builder
    @href_builder || ->(o){o}
  end

  def self.href_builder= value
    @href_builder = value
  end
end

require 'brief/core_ext'
require 'brief/version'
require 'brief/util'
require 'brief/configuration'
require 'brief/document/attachments'
require 'brief/document/rendering'
require 'brief/document/front_matter'
require 'brief/document/templating'
require 'brief/document/content_extractor'
require 'brief/document/transformer'
require 'brief/document/structure'
require 'brief/document/section'
require 'brief/document/section/mapping'
require 'brief/document/section/builder'
require 'brief/document/source_map'
require 'brief/document'
require 'brief/document_mapper'
require 'brief/repository'
require 'brief/model'
require 'brief/model/definition'
require 'brief/model/persistence'
require 'brief/model/serializers'
require 'brief/model/reports'
require 'brief/remote_syncing'
require 'brief/data'
require 'brief/dsl'
require 'brief/server'
require 'brief/briefcase/documentation'
require 'brief/briefcase'
require 'brief/apps'

Brief::Apps.create_namespaces()
Brief.activate_adapter("middleman_extension").activate_brief_extension() if defined?(::Middleman)
