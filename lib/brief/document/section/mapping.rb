class Brief::Document::Section
  class Mapping
    def initialize(title, options={})
      @title = title
      @options = options
      @config  = {}.to_mash
    end

    def selectors
      selector_config.keys
    end

    def selector_config
      config.selectors
    end

    def config
      @config
    end

    def options
      @options
    end

    def title
      @title
    end

    def selector
      @selector || :next
    end

    def each(*args, &block)
      @selector = args.first
      self
    end

    def heading(*args, &block)
      send(:each, *args, &block)
    end

    def has(*args)
      options = args.extract_options!

      unless options.empty?
        config.selectors ||= {}
        config.selectors.merge!(selector => options)
      end

      self
    end

    def is_a(*args)
      options = args.extract_options!
      klass = args.first
      options[:is_a] = klass if klass

      self
    end
  end
end
