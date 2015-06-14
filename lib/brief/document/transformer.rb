# The Document Transformer allows for special usage of markdown
# link and image embedding syntax.  This lets us piggy back on these syntax
# and use them as include directives to embed other documents, or SVG diagrams.
module Brief
  class Document::Transformer
    attr_reader :document, :fragment

    def initialize(fragment, document)
      @fragment = fragment
      @document = document
    end

    def all
      transform_dynamic_links
      inline_svg_content
    end

    def briefcase
      @briefcase ||= document.briefcase
    end

    def inline_svg_content
      inline_svg_images.each do |img|
        src = img['src'].to_s

        if src.match(/=/)
          _, value = img['src'].to_s.split("=")
        else
          value = src
        end

        begin
          if asset = briefcase.find_asset(value)
            img.replace("<div class='svg-wrapper'>#{ asset.read }</div>")
          end
        rescue
          nil
        end
      end
    end

    def transform_dynamic_links
      dynamic_link_elements.each do |node|
        attribute, value = node['href'].to_s.split("=")
        instruction, strategy = node.text.to_s.split(':')

        if instruction == "link" && attribute == "path"
          begin
            link_to_doc = briefcase.document_at(value)

            if link_to_doc.exist?
              text = link_to_doc.send(strategy)
              node.inner_html = text
              node['href'] = briefcase.get_href_for("brief://#{ link_to_doc.path }")
            else
              node['href'] = briefcase.get_href_for("brief://document-not-found")
            end
          rescue
            nil
          end
        end
      end

      include_link_elements.each do |node|
        attribute, value = node['href'].to_s.split("=")
        instruction, strategy = node.text.to_s.split(':')

        if instruction == "include" && attribute == "path"
          include_doc = briefcase.document_at(value)

          replacement = nil

          if strategy == "raw_content"
            replacement = include_doc.unwrapped_html
          elsif strategy == "content"
            replacement = include_doc.to_html
          end

          node.replace(replacement) if replacement
        end
      end
    rescue
      nil
    end

    private

    def inline_svg_images
      fragment.css('img[alt="inline:svg"]')
    end

    def dynamic_link_elements(needle="link:")
      fragment.css('a:contains("' + needle + '")')
    end

    def include_link_elements
      dynamic_link_elements("include:")
    end
  end
end

