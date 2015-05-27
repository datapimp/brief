class Brief::Document::Section
  BuilderError = Class.new(Exception)

  class Builder
    def self.run(source, options = {})
      new(source, options).to_fragment
    end

    attr_accessor :source, :nodes, :low, :high

    def initialize(source, options = {})
      @source = source.map do |item|
        level, group = item
        [level, group.map { |f| f.is_a?(String) ? Nokogiri::HTML.fragment(f) : f }]
      end

      @low = options.fetch(:low, 1)
      @high = options.fetch(:high, 6)
      @nodes = []
      @cycles = 0

      begin
        run
      rescue
        raise BuilderError, $!
      end
    end

    def run
      source.length.times do
        source.each_with_index do |item, index|
          n = index + 1
          level, fragments = item
          next_level, next_fragments = source[n]

          if next_level && (next_level == level) && (level > low)
            new_fragment = (fragments + next_fragments).map(&:to_html).join('')
            source[index] = [level, [Nokogiri::HTML.fragment(new_fragment)]]
            source[n] = nil
          end
        end

        source.compact!
      end

      until even? || maxed_out?
        source.map! do |item|
          level, fragments = item

          [level, (fragments && fragments.first)]
        end

        if source.any? {|i| i[1].nil? }
          raise BuilderError, 'Fragments by level seems invalid'
        end

        source.each_with_index do |item, index|
          level, fragment = item
          n = index + 1
          next_level, next_fragment = source[n]

          if fragment && next_level && (next_level > level)
            parent = fragment.css('section, article').first
            parent.add_child(next_fragment)
            source[index] = [level, fragment]
            source[n] = nil
          end
        end

        source.compact!

        @cycles += 1
      end

      self.nodes = source.map(&:last).flatten

      nodes.each do |node|
        parent = node.css('section, article').first
        parents_first_el = parent && parent.children.first

        if parents_first_el && %w(h1 h2 h3 h4 h5 h6).include?(parent.children.first.name)
          parent['data-heading'] = parents_first_el.text
        end
      end

      nodes.map!(&:to_html)
    end

    def maxed_out?
      @cycles > source.length
    end

    def even?
      source.map(&:first).uniq.length == 1
    end

    def to_fragment
      @html = nodes.join('') unless nodes.empty?
      Nokogiri::HTML.fragment(@html || '<div/>')
    end
  end
end
