require 'pathname'
require 'set'
require 'hashie'
require 'virtus'
require 'inflecto'
require 'active_support'
require 'active_support/core_ext'
require 'github/markdown'
require 'nokogiri'
require 'yaml'
require 'erb'

module Brief

  def self.cases
    @cases ||= {}
  end

  def self.case=(value)
    @briefcase = value
  end

  def self.case
    @briefcase
  end

  def self.views
    @views ||= {}
  end

  def self.configuration
    Brief::Configuration.instance
  end

  def self.gem_root
    Pathname(File.dirname(__FILE__))
  end

  def self.apps_path
    gem_root.join("..","apps")
  end

  def self.load_commands
    Dir[gem_root.join('brief', 'cli', '**/*.rb')].each { |f| require(f) }

    # the instance methods which get defined with the helper
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
end

require 'brief/core_ext'
require 'brief/version'
require 'brief/util'
require 'brief/configuration'
require 'brief/document/rendering'
require 'brief/document/front_matter'
require 'brief/document/templating'
require 'brief/document/content_extractor'
require 'brief/document/structure'
require 'brief/document/section'
require 'brief/document/section/mapping'
require 'brief/document/section/builder'
require 'brief/document'
require 'brief/document_mapper'
require 'brief/repository'
require 'brief/model'
require 'brief/model/definition'
require 'brief/model/persistence'
require 'brief/model/serializers'
require 'brief/model/serializers'
require 'brief/data'
require 'brief/dsl'
require 'brief/server'
require 'brief/briefcase'
require 'brief/apps'

Brief::Apps.create_namespaces()
Brief.activate_adapter("middleman_extension").activate_brief_extension() if defined?(::Middleman)
