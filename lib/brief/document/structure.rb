module Brief
  class Document::Structure
    attr_accessor :fragment, :content_lines

    def initialize(fragment,content_lines=[])
      @fragment = fragment
      @content_lines = content_lines
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

    def create_wrappers
      return if @elements_have_been_wrapped

      elements      = fragment.children

      mapping = []
      bucket = []

      current_level = Util.level(elements.first)

      elements.each_cons(2) do |element, next_element|
        bucket << element

        if Util.is_header?(next_element) && Util.level(next_element) >= current_level
          mapping.push([current_level, bucket])
          bucket = []
        end

        if Util.is_header?(element)
          current_level = Util.level(element)
        end
      end

      mapping.push([current_level, bucket]) unless mapping.include?(bucket)

      base_fragment = Nokogiri::HTML.fragment("<div class='brief top level' />")

      mapping.map! do |item|
        level, group = item
        group.reject! {|i| i.text == "\n" }

        if level == 0
          base_fragment = fragment = Nokogiri::HTML.fragment("<div class='brief top level'>#{ group.map(&:to_html).join("") }</div>")
        elsif level <= lowest_level
          fragment = Nokogiri::HTML.fragment("<section>#{ group.map(&:to_html).join("") }</section>")
        elsif level > lowest_level
          # should be able to look at the document section mappings and
          # apply custom css classes to these based on the name of the section
          fragment = Nokogiri::HTML.fragment("<article>#{ group.map(&:to_html).join("") }</article>")
        end

        [level, [fragment]]
      end

      self.fragment = Brief::Document::Section::Builder.run(mapping, low: lowest_level, high: highest_level)
    end

    def levels
      l = fragment.css("[data-level]").map {|el| el.attr('data-level').to_i }
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

    def heading_with_text(text)
      headings_with_text(text).tap do |results|
        raise 'no section found with content: ' + text if results.length == 0
        raise 'more than one section found with content: ' + text if results.length >= 2

      end.first
    end

    def headings_with_text(text)
      heading_elements.select do |el|
        el.heading.to_s.strip == text.to_s.strip
      end
    end

    def find_heading_by(level, heading)
      heading_elements.find do |el|
        el.level.to_s == level.to_s && heading.to_s.strip == el.heading.to_s.strip
      end
    end

    def heading_elements
      @heading_elements ||= fragment.css("h1,h2,h3,h4,h5,h6").map do |el|
        if el.attr('data-level').to_i > 0
          {
            level: el.attr('data-level'),
            heading: el.attr('data-heading'),
            element: el
          }.to_mash
        end
      end.compact
    end

    class Util
      class << self
        def is_header?(element)
          element.name.to_s.downcase.match(/^h\d$/)
        end

        def level(element)
          element.name.to_s.gsub(/^h/i,'').to_i
        end
      end
    end
  end
end
