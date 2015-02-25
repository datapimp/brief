module Brief
  class Document::ContentExtractor
    def initialize(model_type, document)
      @model_type = model_type
      @document = document
    end

    attr_reader :document

    def model_class
      document.model_class
    end

    def content_schema_attributes
      model_class.definition.content_schema.attributes.symbolize_keys!
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
      supports_extraction?(meth) || super
    end

    def extraction_rule_for(attribute)
      content_schema_attributes.fetch(attribute.to_sym, nil)
    end

    def selector_for(attribute)
      extraction_rule_for(attribute).first
    end

    def supports_extraction?(attribute)
      content_schema_attributes.key?(attribute.to_sym)
    end

    def method_missing(meth, *_args, &_block)
      return super unless supports_extraction?(meth)
      rule = ExtractionRule.new(extraction_rule_for(meth))
      rule.apply_to(document)
    end

    class ExtractionRule
      attr_reader :rule, :args

      def initialize(rule)
        @rule = rule
        @args = rule.args
      end

      def options
        args[1] || {}.to_mash
      end

      def deserialize?
        !!(options.serialize.present? && options.serialize)
      end

      def format
        options.serialize.to_sym
      end

      def selector
        args.first if args.first.is_a?(String)
      end

      def apply_to(document)
        raise 'Must specify a selector' unless selector

        extracted = document.css(selector)

        return nil if extracted.length == 0

        case
        when deserialize? && format == :json
          (JSON.parse(extracted.text.to_s) rescue {}).to_mash
        when deserialize? && format == :yaml
          (YAML.load(extracted.text.to_s) rescue {}).to_mash
        when selector.match(/first-of-type/) && extracted.length > 0
          extracted.first.text
        else
          extracted.map(&:text)
        end
      end
    end
  end
end
