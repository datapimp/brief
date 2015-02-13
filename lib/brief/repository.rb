module Brief
  class Repository
    attr_reader :briefcase, :options

    include Enumerable

    # should compare vs yield
    def each(*args, &block)
      documents.send(:each, *args, &block)
    end

    def initialize(briefcase, options = {})
      @briefcase = briefcase
      @options = options

      load_documents
    end

    def document_at(path)
      path = normalize_path(path)
      Brief::Document.new(path)
    end

    def documents_at!(*paths)
      documents_at(*paths).select {|doc| doc.path.exist? }
    end

    def normalize_path(p)
      docs_path.join(p)
    end

    def documents_at(*paths)
      paths.compact!

      paths.map! {|p| normalize_path(p) }

      paths.map {|p| p && Brief::Document.new(p)}
    end

    def models_at(*paths)
      documents_at(*paths).map(&:to_model)
    end

    def documents
      return @documents if @documents
      load_documents
    end

    def where(*args)
      Brief::DocumentMapper::Query.new(self).send(:where, *args)
    end

    def order_by(*args)
      Brief::DocumentMapper::Query.new(self).send(:order_by, *args)
    end

    def root
      briefcase.root
    end

    def docs_path
      briefcase.docs_path
    end

    def load_documents
      @documents = document_paths.map do |path|
        Brief::Document.new(path).in_briefcase(briefcase)
      end
    end

    def document_paths
      Dir[root.join('**/*.md').to_s].map { |p| Pathname(p) }
    end

    def self.define_document_finder_methods
      # Create a finder method on the repository
      # which lets us find instances of models by their class name
      Brief::Model.table.keys.each do |type|
        plural = type.to_s.pluralize

        define_method("#{ plural }") do
          instance_variable_get("@#{ plural }") || send("#{ plural }!")
        end

        define_method("#{ plural }!") do
          instance_variable_set("@#{plural}", Brief::Model.for_type(type).models.to_a)
          instance_variable_get("@#{ plural }")
        end
      end
    end
  end
end
