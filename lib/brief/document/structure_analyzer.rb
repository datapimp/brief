module Brief
  class Document::StructureAnalyzer
    attr_reader :parser, :content_lines

    def initialize(parser,content_lines=[])
      @parser = parser
      @content_lines = content_lines
      prescan
    end

    def prescan
      content_lines.each_with_index do |line, index|
        if line.match(/^#/)
          line = line.strip
          level = line.count('#')
          text = line.gsub('#','').strip

          if level > 0 && text.length > 0
            line_number = index + 1
            heading = find_heading_by(level, text)

            if heading
              heading.element.set_attribute('data-line-number', line_number)
            end
          end
        end
      end
    end

    def sections
      Array((lowest_level)..(highest_level)).inject({}) do |memo, level|
        headings_at_level(level).each do |h|
          memo[h.heading] ||= h.dup
        end

        memo
      end
    end

    def levels
      l = parser.css("[data-level]").map {|el| el.attr('data-level').to_i }
      l.reject!(&:nil?)
      l.reject! {|v| v.to_i == 0 }
      l.uniq!
      l
    end

    def highest_level
      levels.max
    end

    def lowest_level
      levels.min
    end

    def headings_at_level(level, options={})
      matches = heading_elements.select {|el| el.level.to_i == level.to_i }

      if options[:text]
        matches.map(&:text)
      else
        matches
      end
    end

    def find_heading_by(level, heading)
      heading_elements.find do |el|
        el.level.to_s == level.to_s && heading.to_s.strip == el.heading.to_s.strip
      end
    end

    def heading_elements
      @heading_elements ||= parser.css("h1,h2,h3,h4,h5,h6").map do |el|
        if el.attr('data-level').to_i > 0
          {
            level: el.attr('data-level'),
            heading: el.attr('data-heading'),
            element: el
          }.to_mash
        end
      end.compact
    end

  end
end
