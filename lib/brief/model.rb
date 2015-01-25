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
      include Persistence

      class_attribute :models, :after_initialization_hooks, :defined_actions

      self.models = Array(self.models).to_set
      self.defined_actions = Array(self.defined_actions).to_set

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

      def method_missing(meth, *args, &block)
        if args.empty?
          if document.respond_to?(meth)
            document.send(meth)
          else
            document.data.key?(meth) ? data[meth] : extracted.send(meth)
          end
        else
          super
        end
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
      classes.each(&:finalize)
    end

    def ==(other)
      self.path == other.path
    end

    def extract_content(options={})
      document.extract_content(options)
    end

    module ClassMethods
      def has_actions?
        definition.has_actions?
      end

      def finalize
        klass = self

        klass.name ||= klass.to_s.split('::').last.humanize
        klass.type_alias ||= klass.name.parameterize.gsub(/-/,'_')

        klass.attribute_set.map(&:name).each do |attr|
          unless klass.method_defined?("find_by_#{ attr }")
            klass.define_singleton_method("find_by_#{ attr }") do |value|
              where(attr => value).first
            end
          end
        end

        klass.definition.apply_config

        Brief::Repository.define_document_finder_methods
      end

      def where(*args, &block)
        Brief::DocumentMapper::Query.new(self).send(:where, *args)
      end

      def each(*args, &block)
        Array(self.models).send(:each, *args, &block)
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

      def section_mapping(*args)
        definition.send(:section_mapping, *args)
      end

      def section_mappings(*args)
        definition.send(:section_mappings, *args)
      end

      def generate_template_content_from(object, include_frontmatter=true)
        @erb ||= ERB.new(template_body)
        content = @erb.result(binding)
        frontmatter = object.slice(*attribute_names)

        base = ""
        base += frontmatter.to_hash.to_yaml + "---\n" if include_frontmatter
        base += content

        base
      end

      def attribute_names
        attribute_set.map(&:name)
      end

      def template_body(*args)
        res = definition.send(:template_body, *args)
        res.to_s.length == 0 ? example_body : res.to_s.strip
      end

      def example_body(*args)
        definition.send(:example_body, *args).to_s.strip
      end

      def method_missing(meth, *args, &block)
        if %w(meta content template example actions helpers).include?(meth.to_s)
          definition.send(meth, *args, &block)
          finalize
        elsif meth.to_s.match(/^on_(.*)_change$/)
          create_change_handler($1, *args, &block)
        else
          super
        end
      end

      def create_change_handler(attribute, *args, &block)
        block.call(self)
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
