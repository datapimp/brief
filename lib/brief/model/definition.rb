module Brief
  class Model::Definition
    attr_accessor :type_alias,
                  :name,
                  :metadata_schema,
                  :content_schema,
                  :options,
                  :defined_helpers

    def initialize(name, options={})
      @name             = name
      @options          = options
      @type_alias       = options.fetch(:type_alias) { name.downcase.parameterize.gsub(/-/,'_') }
      @metadata_schema  = {}.to_mash
      @content_schema   = {attributes:{}}.to_mash
      @model_class      = options[:model_class]
    end

    def valid?
      name.to_s.length > 0 && type_alias.to_s.length > 0
    end

    def validate!
      definition = self

      if valid?
        create_model_class.tap do |k|
          k.send(:include, Brief::Model)

          k.definition = definition

          k.name ||= name
          k.type_alias ||= type_alias

          Brief::Model.classes << k
        end

        apply_config
      end
    end

    def apply_config
      metadata_schema.values.each do |settings|
        if model_class.nil?
          binding.pry
        end

        model_class.send(:attribute, *(settings[:args]))
      end

      Array(self.defined_helpers).each do |mod|
        model_class.send(:include, mod)
      end
    end

    def create_model_class
      model_namespace.const_set(type_alias.camelize, Class.new) unless model_class
    end

    def model_class
      @model_class || model_namespace.const_get(type_alias.camelize) rescue nil
    end

    def model_namespace
      Brief.configuration.model_namespace || Brief::Model
    end

    def meta(options={}, &block)
      @current = :meta
      instance_eval(&block)
    end

    def content(options={}, &block)
      @current = :content
      instance_eval(&block)
    end

    def helpers(&block)
      self.defined_helpers ||= []

      if block
        mod = Module.new
        mod.module_eval(&block)

        self.defined_helpers << mod
      end
    end

    def inside_meta?
      @current == :meta
    end

    def inside_content?
      @current == :content
    end

    def method_missing(meth, *args, &block)
      args = args.dup

      if inside_content?
        if meth.to_s == :define_section

        end

        self.content_schema.attributes[meth] = {args: args, block: block}
      elsif inside_meta?
        if args.first.is_a?(Hash)
          args.unshift(String)
        end
        args.unshift(meth)
        self.metadata_schema[meth] = {args: args, block: block}
      else
        super
      end
    end
  end
end
