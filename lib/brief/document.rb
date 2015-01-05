module Brief
  class Document
    include Brief::Document::Rendering
    include Brief::Document::FrontMatter

    attr_accessor :path, :content, :frontmatter

    def initialize(path, options={})
      @path = Pathname(path)
      @options = options

      if self.path.exist?
        content
        load_frontmatter
      end

      self.model_class.try(:models).try(:<<, to_model) unless model_instance_registered?
    end

    def content
      @content ||= path.read
    end

    def extract_content(*args)
      options = args.extract_options!
      args    = options[:args] if options.is_a?(Hash) && options.key?(:args)

      case
      when args.length == 1 && args.first.is_a?(String)
        css(args.first).try(:text).to_s
      end
    end

    def data
      frontmatter
    end

    def extension
      path.extname
    end

    def to_model
      model_class.new(data.to_hash.merge(path: path, document: self)) if model_class
    end

    def model_class
      @model_class || ((data && data.type) && Brief::Model.for_type(data.type))
    end

    # Each model class tracks the instances of the models created
    # and ensures that there is a 1-1 relationship between a document path
    # and the model.
    def model_instance_registered?
      self.model_class && self.model_class.models.any? do |model|
        model.path == self.path
      end
    end

    def respond_to?(method)
      super || data.respond_to?(method)
    end

    def method_missing(meth, *args, &block)
      if data.respond_to?(meth)
        data.send(meth, *args, &block)
      else
        super
      end
    end

  end
end

