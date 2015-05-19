module Brief
  class Document
    include Brief::Document::Rendering
    include Brief::Document::FrontMatter
    include Brief::Document::Templating
    include Brief::Document::Attachments

    def self.from_contents(content, frontmatter, &block)
    end

    attr_accessor :path, :content, :frontmatter, :raw_content, :options

    def initialize(path, options = {})
      if path.respond_to?(:key?) && options.empty?
        @frontmatter = path.to_mash
      else
        @path = Pathname(path)
      end

      @options = options.to_mash

      if @path && self.path.exist?
        @raw_content = self.path.read
        load_frontmatter
      elsif options[:contents]
        @raw_content = options[:contents]
      end
    end

    def document
      self
    end

    def title
      (data && data.title) || css('h1:first-of-type').text || path.to_s.split("/").last.gsub(/\..*/,'')
    end

    def to_s
      "#{ model_class }.at_path(#{relative_path})"
    end

    def inspect
      "#{ model_class }.at_path(#{relative_path})"
    end

    def relative_path
      briefcase.present? ? path.relative_path_from(briefcase.docs_path) : path
    end

    def content_hash
      Digest::MD5.hexdigest(@content.to_s)
    end

    def file_hash
      Digest::MD5.hexdigest(path.read.to_s)
    end

    def content_stale?
      content_hash != file_hash
    end

    def raw= val
      @raw_set = true
      @raw_content = val
      #document.load_frontmatter
      @raw_content
    end

    def set_raw?
      !!@raw_set
    end

    def save
      if set_raw?
        file_contents = raw_content
      else
        file_contents = combined_data_and_content
      end

      path.open('w') {|fh| fh.write(file_contents) }
      refresh!
    end

    def refresh!
      @content = nil
      @raw_content = path.read
      @frontmatter = nil
      @raw_frontmatter = nil
      @refreshing = true
      @content_hash = nil
      load_frontmatter
      true
    end

    def save!
      if set_raw?
        file_contents = raw_content
      else
        file_contents = combined_data_and_content
      end

      path.open('w+') {|fh| fh.write(file_contents) }
      refresh!
    end

    def combined_data_and_content
      return content if data.nil? || data.empty?
      frontmatter.to_hash.to_yaml + "---\n\n#{ content }"
    end

    def data
      frontmatter
    end

    def include_attachments?
      attachments.length > 0
    end

    def attachments
      Array(data.attachments)
    end

    def in_briefcase(briefcase)
      @briefcase_root = briefcase.root

      unless Brief::Util.ensure_child_path(briefcase.docs_path, path)
        raise 'Invalid document path'
      end

      self
    end

    def briefcase
      (@briefcase_root && Brief.cases[@briefcase_root.basename.to_s]) || Brief.case(true)
    end

    def has_sections?
      model_class.section_mappings.length > 0
    end

    def section_headings
      sections.keys
    end

    def sections_data
      section_headings.reduce({}) do |memo, heading|
        section = sections.send(heading)
        items = section.items rescue nil
        memo[heading] = items if items
        memo
      end
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

    def content= value
      @content = value
    end

    def content
      if @content.nil? && path && path.exist?
        @content = path.read
      end

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

    def model_attributes
      (data || {}).to_hash
        .merge(path: path, document: self)
        .reverse_merge(type: document_type)
    end

    def to_model
      model_class.try(:new, model_attributes)
    end

    def exist?
      path && path.exist?
    end

    def model_class
      case
      when @model_class
        @model_class
      when briefcase
        briefcase.model_class_for(self)
      when data && data.type
        Brief::Model.for_type(data.type)
      when parent_folder_name.length > 0
        Brief::Model.for_folder_name(parent_folder_name)
      else
        raise 'Could not determine the model class to use for this document. Specify the type, or put it in a folder that maps to the correct type.'
      end
    end

    def document_type
      options.fetch(:type) { document_type! }
    end

    def document_type!
      existing = data && data.type
      return existing if existing
      parent_folder_name.try(:singularize)
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

    def respond_to?(*args)
      method = args.first
      super || (data && data.respond_to?(method)) || (data && data.key?(method))
    end

    # The structure analyzer of the document is responsible for grouping
    # the content under the headings by wrapping them in divs, and creating
    # relationships between the nodes. This is what lets us provide an easy
    # iteration API on top of the parsed document
    def structure
      @structure_analyzer ||= Brief::Document::Structure.new(fragment, raw_content.lines.to_a)
    end

    # The Parser wraps the rendered HTML in a nokogiri element so we can easily manipulate it.
    # Prior to doing so, we use the structure analyzer to build more metadata into the markup
    def parser
      @parser ||= begin
                    structure.prescan

                    structure.create_wrappers.tap do |f|
                      transformer_for(f).all if data.transform
                    end
                  end
    end

    # The transformer is responsible for performing content modifications
    # on the rendered document.  This is useful for supporting extensions that
    # are driven by the markdown language.
    #
    # TODO: This is hidden behind a feature flag, and requires the document
    # to have metadata that specifies transform = true
    def transformer_for(doc_fragment=nil)
      doc_fragment ||= fragment
      @transformer ||= Brief::Document::Transformer.new(doc_fragment, self)
    end

    def fragment
      @fragment ||= Nokogiri::HTML.fragment(to_raw_html)
    end

    def type
      document_type
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
