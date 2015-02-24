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
      found = documents.find {|doc| doc.path == path }
      found || Brief::Document.new(path).in_briefcase(briefcase)
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

      paths.map {|p| p && document_at(p) }
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

    def all_models
      list = documents.map(&:to_model)
      list.compact!
      list.select!(&:exists?)

      list
    end

    def all_models_by_type
      all_models.reduce({}) do |memo, model|
        (memo[model.class.type_alias] ||= []) << model if model.exists?
        memo
      end
    end

    def purge(model_type=nil)
      if model_type
        plural = model_type.to_s.pluralize

        if instance_variable_get("@#{ plural }")
          instance_variable_set("@#{plural}",nil)
        end
      end

      documents.reject! {|doc| !doc.path.exist? }
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
          instance_variable_set("@#{plural}", Brief::Model.existing_models_for_type(type))
          instance_variable_get("@#{ plural }")
        end
      end
    end
  end
end
