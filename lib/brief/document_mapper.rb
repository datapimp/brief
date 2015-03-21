# Credit to github.com/ralph/document_mapper
module Brief::DocumentMapper
  OPERATOR_MAPPING = {
    'equal'     => :==,
    'eq'        => :==,
    'neq'       => :!=,
    'not_equal' => :!=,
    'gt'        => :>,
    'gte'       => :>=,
    'in'        => :in?,
    'include'   => :include?,
    'lt'        => :<,
    'lte'       => :<=
  }

  VALID_OPERATORS = OPERATOR_MAPPING.keys

  class Selector
    attr_reader :attribute, :operator

    def initialize(opts = {})
      unless Brief::DocumentMapper::VALID_OPERATORS.include?(opts[:operator])
        fail 'Operator not supported'
      end

      @attribute, @operator = opts[:attribute], opts[:operator]
    end
  end

  class Query
    attr_reader :model

    def initialize(model)
      @model = model
      @where = {}
    end

    def where(constraints_hash)
      selector_hash = constraints_hash.reject { |key, _value| !key.is_a? Selector }
      symbol_hash = constraints_hash.reject { |key, _value| key.is_a? Selector }
      symbol_hash.each do |attribute, value|
        selector = Selector.new(attribute: attribute, operator: 'equal')
        selector_hash.update(selector => value)
      end
      @where.merge! selector_hash
      self
    end

    def order_by(field)
      @order_by = field.is_a?(Symbol) ? { field => :asc } : field
      self
    end

    def offset(number)
      @offset = number
      self
    end

    def limit(number)
      @limit = number
      self
    end

    def first
      all.first
    end

    def last
      all.last
    end

    def run_query
      if query_is_empty?
        model.to_a
      else
        model.select do |obj|
          match = true

          @where.each do |selector, value|
            obj = obj.symbolize_keys if obj.is_a?(Hash)

            if obj.respond_to?(selector.attribute)
              test_value = obj.send(selector.attribute)
              operator   = OPERATOR_MAPPING[selector.operator]
              match      = false unless test_value.send(operator, value)
            elsif obj.key?(selector.attribute.to_sym)
              test_value = obj.send(:[], selector.attribute.to_sym)
              operator   = OPERATOR_MAPPING[selector.operator]
              match      = false unless test_value.send(operator, value)
            else
              match      = false
            end
          end

          match
        end
      end
    end

    def all
      results = run_query

      if @order_by
        order_by_attr = @order_by.keys.first
        direction     = @order_by.values.first

        results.select! do |result|
          result.respond_to?(order_by_attr)
        end

        results.sort_by! do |result|
          result.send(order_by_attr)
        end

        results.reverse! if direction == :desc
      end

      if @offset.present?
        results = results.last([results.size - @offset, 0].max)
      end

      if @limit.present?
        results = results.first(@limit)
      end

      results
    end

    def to_a
      all
    end

    def query_is_empty?
      @where.empty? && @limit.nil? && @order_by.nil?
    end

    def inspect
      "Query: #{ @where.map { |k, v| "#{k.attribute} #{k.operator} #{v}" }}"
    end

    def method_missing(meth, *args, &block)
      if all.respond_to?(meth)
        all.send(meth, *args, &block)
      else
        super
      end
    end
  end
end

class Symbol
  Brief::DocumentMapper::VALID_OPERATORS.each do |operator|
    class_eval <<-OPERATORS
      def #{operator}
        Brief::DocumentMapper::Selector.new(:attribute => self, :operator => '#{operator}')
      end
    OPERATORS
  end

  unless method_defined?(:"<=>")
    def <=>(other)
      to_s <=> other.to_s
    end
  end
end
