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
      include Serializers
      include Reports

      class_attribute :models, :after_initialization_hooks

      self.models = Array(models).to_set

      class << self
        include Enumerable
      end

      attribute :path, Pathname
      attribute :document, Brief::Document

      Brief::Model.classes << self
    end

    module AccessorMethods
      def title
        document_title
      end

      def document_title
        data.try(:[], :title) ||
        extracted_content_data.try(:title) ||
        path.basename.to_s
          .gsub(/\.html.md/,'')
          .gsub(/\.md/,'')
      end

      def data
        document.data || {}.to_mash
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
            document.send(meth, *args, &block)
          else
            document.data && document.data.key?(meth) ? data[meth] : extracted.send(meth)
          end
        else
          super
        end
      end

      def exists?
        document && document.path && document.path.exist?
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

    def self.lookup(type_alias)
      for_type(type_alias) || for_folder_name(type_alias) || for_type(type_alias.singularize)
    end

    def self.for_type(type_alias)
      table[type_alias]
    end

    def self.existing_models_for_type(type_alias)
      klass = for_type(type_alias)
      klass.models.select(&:exists?)
    end

    def self.for_folder_name(folder_name=nil)
      folder_name = folder_name.to_s.downcase
      table[folder_name.singularize] || table[folder_name]
    end

    def self.lookup_class_from_args(args = [])
      args = Array(args)

      if model_class = for_type(args.first)
        model_class
      end
    end

    def self.finalize
      Virtus.finalize
      classes.each(&:finalize)
    end

    def ==(other)
      path == other.path
    end

    def extract_content(options = {})
      document.extract_content(options)
    end

    module ClassMethods
      def ==(other)
        type_alias && type_alias == other.type_alias
      end

      def accessor_property_names
        (definition.content_schema.attributes.keys + definition.metadata_schema.keys).uniq
      end

      # Looks to see if there is a documentation markdown file for the model
      # and if so, will return the documentation info as a Hash
      def to_documentation
        docs = definition.documentation

        path = if docs.markdown
                 Pathname(docs.markdown)
               elsif defined_in
                 basename = defined_in.basename.to_s.gsub(/.rb/,'')
                 defined_in.parent.join('..','documentation',"#{basename}.md")
               end

        if path
          model_doc = Brief::Briefcase::Documentation::ModelDoc.new(path)

          {
            content: model_doc.content,
            rendered: model_doc.rendered,
            path: path
          }
        else
          { }
        end
      end

      def content_schema_summary
        base = definition.content_schema.attributes

        base.keys.inject({}) do |memo, key|
          val = base[key]
          args = Array(val[:args])
          first = args.first
          memo[key] = first if first
          memo
        end
      end

      def metadata_schema_summary
        base = definition.metadata_schema

        base.keys.inject({}) do |memo, key|
          val = base[key]
          args = Array(val[:args])
          first = args.first.to_s

          if args.length == 1 && first == key.to_s
            memo[key] = "string"
          elsif args.length >= 2
            memo[key] = args.last
          end

          memo
        end
      end

      def example_content
        if example_path && example_path.exist?
          return example_path.read.to_s
        end

        definition.example_body.to_s
      end

      def template_content
        if template_path && template_path.exist?
          return template_path.read.to_s
        end

        definition.template_body.to_s
      end

      def documentation_content
        if documentation_path && documentation_path.exist?
          return documentation_path.read.to_s
        end
      end

      def to_schema
        {
          schema: {
            content: content_schema_summary,
            metadata: metadata_schema_summary,
          },
          documentation: to_documentation,
          defined_in: defined_in,
          class_name: to_s,
          type_alias: type_alias,
          name: name,
          group: name.to_s.pluralize,
          actions: defined_actions,
          example: example_content,
          template: template_content,
          urls: {
            browse_url: "browse/#{ type_alias.to_s.pluralize }",
            schema_url: "schema/#{ type_alias }"
          }
        }
      end

      def has_actions?
        definition.has_actions?
      end

      def defined_actions
        definition.defined_actions ||= []
      end

      def finalize
        klass = self

        klass.name ||= klass.to_s.split('::').last.humanize
        klass.type_alias ||= klass.name.parameterize.gsub(/-/, '_')

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

      def where(*args, &_block)
        Brief::DocumentMapper::Query.new(self).send(:where, *args)
      end

      def each(*args, &block)
        Array(models).send(:each, *args, &block)
      end

      def after_initialize(&block)
        (self.after_initialization_hooks ||= []).push(block)
      end

      attr_writer :name

      def name
        @name || to_s.split('::').last.underscore.gsub('_', ' ').titlecase
      end

      attr_writer :type_alias

      def type_alias
        @type_alias || name.parameterize.gsub(/-/, '_')
      end

      def definition
        @definition ||= Brief::Model::Definition.new(name, type_alias: type_alias, model_class: self)
      end

      def definition=(_value)
        @definition
      end

      def section_mapping(*args)
        definition.send(:section_mapping, *args)
      end

      def section_mappings(*args)
        definition.send(:section_mappings, *args)
      end

      def generate_template_content_from(object={}, include_frontmatter = true)
        @erb ||= ERB.new(template_body)
        content = @erb.result(binding)
        frontmatter = object.slice(*attribute_names)

        base = ''
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

      def new_doc_template(&block)
        if block
          definition.new_doc_template_block = block
        elsif definition.new_doc_template_block
          definition.new_doc_template_block.call
        else
          example_content
        end
      end

      def new_doc_name(&block)
        if block
          definition.new_doc_name_block = block
        elsif definition.new_doc_name_block
          definition.new_doc_name_block.call
        else
          "#{ self.type_alias }-#{ DateTime.now.strftime("%Y-%m-%d") }.md"
        end
      end

      def documentation(*args)
        definition.send(:documentation, *args)
      end

      def defined_in(*args)
        definition.send(:defined_in, *args)
      end

      def template_path(*args)
        definition.send(:template_path=, *args) unless args.empty?
        definition.send(:template_path)
      end

      def example_path(*args)
        definition.send(:example_path=, *args) unless args.empty?
        definition.send(:example_path)
      end

      def documentation_path(*args)
        definition.send(:documentation_path=, *args) unless args.empty?
        definition.send(:documentation_path)
      end

      def method_missing(meth, *args, &block)
        # these methods have a special effect on the behavior of the
        # model definition.  we need to make sure we call finalize after
        # them
        if %w(meta content template example actions helpers).include?(meth.to_s)
          definition.send(meth, *args, &block)
          finalize
        elsif %w(defined_helper_methods defined_actions).include?(meth.to_s)
          definition.send(meth)
        elsif meth.to_s.match(/^on_(.*)_change$/)
          create_change_handler(Regexp.last_match[1], *args, &block)
        else
          super
        end
      end

      def create_change_handler(_attribute, *_args, &block)
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

      def set_slug_from(column = :name)
        self.slug = send(column).to_s.downcase.parameterize if slug.to_s.length == 0
      end
    end
  end
end
