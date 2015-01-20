class Brief::Document::Section
  def initialize(title, fragment, options={})
  end
end

class Brief::Document::Section
  class Mapping
    def initialize(title, options={})
      @title = title
      @options = options
    end

    def for_each(*args, &block)
      self
    end

    def heading(*args, &block)
      self
    end

    def has(*args)
      self
    end

    def is_a(*args)
      self
    end
  end
end
