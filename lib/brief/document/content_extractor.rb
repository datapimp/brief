module Brief
  class Document::ContentExtractor
    def initialize(model_type, document)
      @model_type = model_type
      @document = document
    end

    attr_reader :document

    def model_class
      Brief::Model.for_type(@model_type)
    end

    def attribute_set
      model_class.definition.content_schema.attributes
    end

    def respond_to?(meth)
      attribute_set.key?(meth) || super
    end

    def method_missing(meth, *_args, &_block)
      if settings = attribute_set.fetch(meth, nil)
        if settings.args.length == 1 && settings.args.first.is_a?(String)
          selector = settings.args.first
          matches = document.css(selector)

          if matches.length > 1
            selector.match(/first-of-type/) ? matches.first.text : matches.map(&:text)
          else
            matches.first.try(:text)
          end
        end
      end
    end
  end
end
