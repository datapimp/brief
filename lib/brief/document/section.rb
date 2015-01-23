class Brief::Document::Section
  attr_accessor :title, :fragment
  attr_reader :config

  Headings = %w(h1 h2 h3 h4 h5 h6)

  def initialize(title, fragment, config)
    @title = title
    @fragment = fragment
    @config = config
  end

  def items
    return @items if @items

    data = []

    config.selectors.each do |selector|
      settings = config.selector_config[selector]

      if Headings.include?(selector)
        headings = fragment.css("article > h2")
        articles = headings.map(&:parent)

        if !settings.empty?
          articles.compact.each do |article|
            data.push(settings.inject({}.to_mash) do |memo, pair|
              attribute, selector = pair
              result = article.css(selector)
              memo[attribute] = result.length > 1 ? result.map(&:text) : result.text
              memo
            end)
          end
        end
      end
    end

    @items = data
  end
end

