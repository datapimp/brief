module Brief
  module Model
    extend ActiveSupport::Concern

    included do
      unless defined?(Virtus)
        require 'inflecto'
        require 'virtus'
      end

      include Virtus.model(finalize: false)
      include Initializers
      include AccessorMethods

      class_attribute :models, :after_initialization_hooks

      self.models = Array(self.models).to_set

      class << self
        include Enumerable
      end

      attribute :path, Pathname
      attribute :document, Brief::Document

      Brief::Model.classes << self
    end

    module AccessorMethods
      def data
        document.data
      end

      def content
        document.content
      end

      def extracted
        @extracted ||= Brief::Document::ContentExtractor.new(self.class.type_alias, document)
      end
    end

    def self.classes
      @classes ||= Set.new
    end

    def self.table
      classes.inject({}.to_mash) do |memo, klass|
        memo.tap { memo[klass.type_alias] = klass }
      end
    end

    def self.for_type(type_alias)
      table[type_alias]
    end

    def self.finalize
      Virtus.finalize

      classes.each do |klass|
        klass.name ||= klass.to_s.split('::').last.humanize
        klass.type_alias ||= klass.name.parameterize.gsub(/-/,'_')

        klass.attribute_set.map(&:name).each do |attr|
          klass.define_singleton_method("find_by_#{ attr }") do |value|
            where(attr => value).first
          end
        end

        klass.definition.apply_meta_settings
      end

      Brief::Repository.define_document_finder_methods
    end

    def ==(other)
      self.path == other.path
    end

    def extract_content(options={})
      document.extract_content(options)
    end

    module ClassMethods
      def content_extractor
        @content_extrator ||= Brief::Document::ContentExtractor.new(self)
      end

      def where(*args, &block)
        Brief::DocumentMapper::Query.new(self).send(:where, *args)
      end

      def each(*args, &block)
        Array(self.models).send(:each, *args, &block)
      end

      def meta(options={}, &block)
        definition.send(:meta, options, &block)
      end

      def content(options={}, &block)
        definition.send(:content, options, &block)
      end

      def after_initialize(&block)
        (self.after_initialization_hooks ||= []).push(block)
      end

      def name=(value)
        @name = value
      end

      def name
        @name || to_s.split('::').last.underscore.gsub('_',' ').titlecase
      end

      def type_alias=(value)
        @type_alias = value
      end

      def type_alias
        @type_alias || name.parameterize.gsub(/-/,'_')
      end

      def definition
        @definition ||= Brief::Model::Definition.new(name, type_alias: type_alias, model_class: self)
      end

      def definition=(value)
        @definition
      end
    end

    module Initializers
      def set_default_attributes
        attribute_set.set_defaults(self)
        send(:after_initialize) if respond_to?(:after_initialize)
        self
      end

      def after_initialize
        Array(self.class.after_initialization_hooks).each do |hook|
          hook.call(self)
        end
      end

      def set_slug_from(column=:name)
        self.slug = send(column).to_s.downcase.parameterize if self.slug.to_s.length == 0
      end
    end

  end
end
