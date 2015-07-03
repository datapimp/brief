module Brief::Document::SourceMap
  def heading_line_numbers
    heading_element_tags.map {|el| el.attr('data-line-number') }
  end

  def heading_element_tags
    css('h1,h2,h4,h5,h6')
  end

  def heading_details
    @heading_details ||= structure.get_heading_details.tap do |list|
      list.map! {|i| i.line_number = i.line_number.to_i; i.level = i.level.to_i; i }
      list.sort_by! {|i| i.line_number }
    end
  end

  def next_sibling_heading_for(heading_element)
    if heading_element.is_a?(String) && heading_element.length > 1
      heading_element = heading_element_tags.find do |el|
        el.attr('data-heading').include?(heading_element) || el.text.to_s.include?(heading_element)
      end
    end

    line  = heading_element.attr('data-line-number').to_i
    level = heading_element.attr('data-level').to_i

    superior = heading_details.find do |next_element|
      next_element.line_number.to_i > line && next_element.level.to_i >= level
    end

    superior && superior.element
  end

  def line_numbers_for_heading(heading_element, include_heading=true)
    if heading_element.nil?
      binding.pry
    end
    if heading_element.is_a?(String) && heading_element.length > 1
      heading_element = heading_element_tags.find do |el|
        el.attr('data-heading').include?(heading_element.strip.downcase) || el.text.to_s.strip.downcase.include?(heading_element.strip.downcase)
      end
    end

    if heading_element.nil?
      binding.pry
    end

    start_index = heading_element.attr('data-line-number').to_i

    if next_heading = next_sibling_heading_for(heading_element)
      end_index = next_heading.attr('data-line-number').to_i
    else
      end_index = raw_content.lines.length + 1
    end

    end_index = end_index - start_index
    start_index = 0 if start_index < 0

    [start_index, end_index]
  end

  def content_under_heading(heading_element, include_heading=true)
    start_index, end_index = line_numbers_for_heading(heading_element, include_heading)
    lines = raw_content.lines.dup.slice(start_index - 1, end_index)
    Array(include_heading ? lines : lines.slice(1, lines.length)).join("")
  end
end
