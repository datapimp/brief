module Brief
  class Document
    include Brief::Document::Rendering
    include Brief::Document::FrontMatter
    include Brief::Document::Templating

    attr_accessor :path, :content, :frontmatter, :raw_content

    def initialize(path, options = {})
      if path.respond_to?(:key?) && options.empty?
        @frontmatter = path.to_mash
      else
        @path = Pathname(path)
      end

      @options = options.to_mash

      if @path && self.path.exist?
        @raw_content = path.read
        load_frontmatter
      elsif options[:contents]
        @raw_content = options[:contents]
      end

      model_class.try(:models).try(:<<, to_model) unless model_instance_registered?
    end

    def data
      frontmatter
    end

    def sections
      mappings = model_class.section_mappings

      @sections = {}.to_mash

      mappings.each do |name, mapping|
        fragment = css("section[data-heading='#{name}']").first
        @sections[name.parameterize.downcase.underscore] = Brief::Document::Section.new(name, fragment, mapping)
      end

      @sections
    end

    def content
      @content || generate_content
    end

    # Shortcut for querying the rendered HTML by css selectors.
    #
    # This will allow for model data attributes to be pulled from the
    # document contents.
    #
    # Returns a Nokogiri::HTML::Element
    def css(*args, &block)
      parser.send(:css, *args, &block)
    end

    # Returns a Nokogiri::HTML::Element
    def at(*args, &block)
      parser.send(:at, *args, &block)
    end

    def extract_content(*args)
      options = args.extract_options!
      args    = options.delete(:args) if options.is_a?(Hash) && options.key?(:args)

      case
      when options.empty? && args.length == 1 && args.first.is_a?(String)
        results = css(args.first)
        results = results.first if results.length > 1 && args.first.match(/:first-of-type/)
        results.try(:text).to_s
      else
        binding.pry
      end
    end

    def relative_path_identifier
      if Brief.case
        path.relative_path_from(Brief.case.root)
      else
        path.to_s
      end
    end

    def extension
      path.extname
    end

    def to_model
      model_class.new(data.to_hash.merge(path: path, document: self)) if model_class
    end

    def model_class
      case
      when @model_class
        @model_class
      when data && data.type
        Brief::Model.for_type(data.type)
      when parent_folder_name.length > 0
        Brief::Model.for_folder_name(parent_folder_name)
      end
    end

    def parent_folder_name
      path.parent.basename.to_s.downcase
    end

    # Each model class tracks the instances of the models created
    # and ensures that there is a 1-1 relationship between a document path
    # and the model.
    def model_instance_registered?
      model_class && model_class.models.any? do |model|
        model.path == path
      end
    end

    def respond_to?(method)
      super || data.respond_to?(method) || data.key?(method)
    end

    def structure
      @structure_analyzer ||= Brief::Document::Structure.new(fragment, raw_content.lines.to_a)
    end

    def parser
      @parser ||= begin
                    structure.prescan
                    structure.create_wrappers
                  end
    end

    def fragment
      @fragment ||= Nokogiri::HTML.fragment(to_raw_html)
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
