require "pathname"
require "set"
require "hashie"
require "virtus"
require "inflecto"
require "active_support"
require "active_support/core_ext"
require "redcarpet"
require "nokogiri"
require "yaml"

module Brief
  def self.case= value
    @briefcase = value
  end

  def self.case
    @briefcase
  end

  def self.configuration
    Brief::Configuration.instance
  end

  def self.gem_root
    Pathname(File.dirname(__FILE__))
  end

  def self.load_commands
    Dir[gem_root.join("brief","cli","**/*.rb")].each {|f| require(f) }

    # the instance methods which get defined with the helper
    Brief::Model.classes.each do |klass|
      Array(klass.defined_actions).uniq.each do |action|
        Brief::Util.create_method_dispatcher_command_for(action, klass)
      end
    end
  end

  def self.load_models(from_folder=nil)
    Brief::Model.load_all(from_folder: from_folder)
  end
end

require "brief/core_ext"
require "brief/version"
require "brief/util"
require "brief/configuration"
require "brief/document/rendering"
require "brief/document/front_matter"
require "brief/document/content_extractor"
require "brief/document"
require "brief/document_mapper"
require "brief/repository"
require "brief/model"
require "brief/model/definition"
require "brief/model/persistence"
require "brief/dsl"
require "brief/briefcase"
