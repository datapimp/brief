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

    def content_schema_attributes
      model_class.definition.content_schema.attributes
    end

    def extracted_content_data
      me = self
      content_schema_attributes.keys.reduce({}.to_mash) do |memo, attr|
        val = me.send(attr) rescue nil
        memo[attr] = val if val
        memo
      end
    end

    def respond_to?(meth)
      content_schema_attributes.key?(meth) || super
    end

    def method_missing(meth, *_args, &_block)
      if settings = content_schema_attributes.fetch(meth, nil)
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
