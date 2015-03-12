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

    def respond_to?(meth)
      super || model_groups.include?(meth.to_s)
    end

    def method_missing(meth, *args, &block)
      in_model_group = model_groups.include?(meth.to_s)

      if in_model_group && args.empty?
        find_models_by_type(meth)
      elsif in_model_group && !args.empty?
        group = find_models_by_type(meth)
        Brief::DocumentMapper::Query.new(group).send(:where, *args)
      else
        super
      end
    end

    def find_models_by_type(group_name)
      type = group_name.to_s.singularize
      all_models_by_type.fetch(type) { [] }
    end

    def model_groups
      documents.map(&:document_type).tap {|l| l.compact!; l.uniq!; l.map! {|i| i.pluralize } }
    end

    def document_at(path)
      path = normalize_path(path)
      found = documents.find {|doc| doc.path == path }
      found || Brief::Document.new(path).in_briefcase(briefcase)
    end

    def documents_at!(*paths)
      documents_at(*paths).select {|doc| doc.path.exist? }
    end

    InvalidPath = Class.new(Exception)

    def normalize_path(p)
      docs_path.join(p).tap do |normalized|
        if normalized.to_s.split("/").length < docs_path.realpath.to_s.split("/").length
          raise InvalidPath
        end
      end
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
      Dir[docs_path.join('**/*.md').to_s].map { |p| Pathname(p) }
    end

    def all_models
      @all_models ||= begin
                        list = documents.select(&:refresh!).map(&:to_model)
                        list.compact!
                        list.select!(&:exists?)

                        list
                      end
    end

    def all_models_by_type
      @all_models_by_type ||= begin
                                all_models.reduce({}) do |memo, model|
                                  (memo[model.class.type_alias.to_s] ||= []) << model if model.exists?
                                  memo
                                end
                              end
    end

    def purge(model_type=nil)
      load_documents
      @all_models_by_type = nil
      @all_models = nil
    end

    def self.define_document_finder_methods
      # Create a finder method on the repository
      # which lets us find instances of models by their class name
      Brief::Model.table.keys.each do |type|

      end
    end
  end
end
