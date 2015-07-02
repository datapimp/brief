# # Structured Documents
#
# Normal markdown is rendered flat.  While there may be hierarchy,
# it was difficult to parse it in a way which made the headings
# collapsible.
#
# The Document Structure is responsible for grouping
# blocks of content under their nearest previous heading element
# acting as a parent.  It does this by wrapping them in `<section>`
# and <article> tags, and through the use of data-attributes on the elements.
#
# ```
# - h1
#   - h2
#     - h3
#     - h3
#   - h2
# - h1
#   - h2
# ```
#
# This class allows for us to define rules based on headings, for how
# we might interpret the meaning of the content that is written.  It allows
# us to say: all level 2 headings are 'TodoItems' if they exist under the level 1 heading 'Tasks'
module Brief
  class Document::Structure
    attr_accessor :fragment, :content_lines

    def initialize(fragment, content_lines = [])
      @fragment = fragment
      @content_lines = content_lines
    end

    def prescan
      set_markings_on_headers
      assign_id_attributes_to_pre_tags
    end

    def assign_id_attributes_to_pre_tags
      pres = fragment.css('pre[lang]')

      pres.each do |pre|
        lang = pre.attr('lang')

        if match_data = lang.match(/\((\w+)\)/)
          pre.set_attribute 'id', match_data.captures.first
          pre.set_attribute 'lang', lang.gsub(/\((\w+)\)/,'')
        end
      end
    end

    def set_markings_on_headers
      content_lines.each_with_index do |line, index|
        if line.match(/^#/)
          line    = line.strip
          level   = line.count('#')
          text    = line.gsub('#', '').strip

          if level > 0 && text.length > 0
            line_number = index + 1

            heading = find_heading_by(level, text)

            # If it is a heading element, we map it to a line number in
            # the content that produced it. We also look for the special
            # syntax {attribute: value; other-attribute: value} which
            # lets us set attributes on the header
            if heading
              set_attributes = {"data-line-number" => line_number}

              if attribute_matchers = line.match(/\{(.*)\}/)
                attributes = attribute_matchers.captures.first.strip
                attributes.split(';').each do |pair|
                  key, value = pair.split(':')
                  set_attributes[key.to_s.strip] = value.to_s.strip
                end

                value = heading.element.text.to_s.split(/\{.*\}/).join("").strip
                heading.element.inner_html = value
                heading.element.set_attribute('data-heading', value)
              end

              set_attributes.each do |k,v|
                heading.element.set_attribute(k, v)
              end
            end
          end
        end
      end
    end

    def heading_element_tags
      css("h1,h2,h3,h4,h5,h6")
    end

    # Markdown rendered HTML comes in the forms of a bunch of siblings,
    # and no parents.  We need to introduce the concept of ownership of
    # sections of the document, by using the heading level (h1 - h6) as
    # a form of rank.
    #
    # All h1 elements will 'own' the h2,h3,h4,h5,h6
    # elements underneath them.
    def create_wrappers
      return if @elements_have_been_wrapped

      elements      = fragment.children

      # The different groups of elements
      mapping = []

      # The current bucket of elements that is being
      # collected, will get reset whenever it runs into
      # an element that is a greater heading rank
      bucket = []

      current_level = Util.level(elements.first)

      elements.each_cons(2) do |element, next_element|
        bucket << element

        # We will have run into a greater header, so close up the bucket
        # and put it into the mapping
        if Util.is_header?(next_element) && Util.level(next_element) >= current_level
          mapping.push([current_level, bucket])
          bucket = []
        end

        if Util.is_header?(element)
          current_level = Util.level(element)
        end
      end

      # we never ended up reaching a header, so close up and move on
      if !mapping.include?(bucket)
        mapping.push([current_level, bucket])
      end

      base_fragment = Nokogiri::HTML.fragment("<div class='brief top level' />")

      mapping.map! do |item|
        level, group = item
        group.reject! { |i| i.text == "\n" }

        #puts "Mapping! #{ level } group length: #{ group.length }"

        if level == 0
          #puts "== Condition A"
          base_fragment = fragment = Nokogiri::HTML.fragment("<div class='brief top level'>#{ group.map(&:to_html).join('') }</div>")
        elsif level <= lowest_level
          #puts "== Condition B"
          fragment = Nokogiri::HTML.fragment("<section>#{ group.map(&:to_html).join('') }</section>")
        elsif level > lowest_level
          #puts "== Condition C"
          # should be able to look at the document section mappings and
          # apply custom css classes to these based on the name of the section
          fragment = Nokogiri::HTML.fragment("<article>#{ group.map(&:to_html).join('') }</article>")
        end

        [level, [fragment]]
      end

      begin
        self.fragment = Brief::Document::Section::Builder.run(mapping, low: lowest_level, high: highest_level)
      rescue Brief::Document::Section::BuilderError
        ##puts "== Error, returning default fragment: #{ $! }"
        @fragment
      end
    end

    def levels
      l = fragment.css('[data-level]').map { |el| el.attr('data-level').to_i }
      l.reject!(&:nil?)
      l.reject! { |v| v.to_i == 0 }
      l.uniq!
      l
    end

    def highest_level
      levels.max
    end

    def lowest_level
      levels.min
    end

    def headings_at_level(level, options = {})
      matches = heading_details.select { |el| el.level.to_i == level.to_i }

      if options[:text]
        matches.map(&:text)
      else
        matches
      end
    end

    def heading_with_text(text)
      headings_with_text(text).tap do |results|
        fail 'no section found with content: ' + text if results.length == 0
        fail 'more than one section found with content: ' + text if results.length >= 2
      end.first
    end

    def headings_with_text(text)
      heading_details.select do |el|
        el.heading.to_s.strip == text.to_s.strip
      end
    end

    def find_pre_by_lang(lang)
      fragment.css("pre[lang='#{lang}']").first
    end

    def find_heading_by(level, heading)
      heading_details.find do |el|
        el.level.to_s == level.to_s && heading.to_s.strip == el.heading.to_s.strip
      end
    end

    def heading_details
      @heading_details ||= get_heading_details
    end

    def get_heading_details
      fragment.css('h1,h2,h3,h4,h5,h6').map do |el|
        if el.attr('data-level').to_i > 0
          {
            level: el.attr('data-level'),
            heading: el.attr('data-heading'),
            line_number: el.attr('data-line-number'),
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
          (element && element.name.to_s.gsub(/^h/i, '')).to_i
        end
      end
    end
  end
end
