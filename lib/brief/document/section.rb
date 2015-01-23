class Brief::Document::Section
  attr_reader :title, :elements, :anchor

  attr_accessor :mapping, :html_method

  include Enumerable

  def initialize(title, anchor)
    @title = title
    @anchor = anchor
    @elements = []
  end

  def each
    @elements
  end

  def <<(el)
    @elements << el
  end

  def fragment
    @fragment ||= Nokogiri::HTML.fragment(to_html)
  end

  def to_html
    fragment.html
  end

end

